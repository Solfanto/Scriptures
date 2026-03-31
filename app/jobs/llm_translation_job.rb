class LlmTranslationJob < ApplicationJob
  queue_as :default

  STYLES = {
    "word_for_word" => {
      abbreviation_suffix: "WFW",
      name_suffix: "Word-for-word",
      instruction: "Produce a strictly literal, word-for-word rendering from the original language into English. " \
        "Arrange the words into clear, natural English word order while preserving each term's core lexical meaning " \
        "and grammatical number (singular/plural), even if it results in unconventional phrasing. " \
        "Do not harmonize or reinterpret plural forms into singular for stylistic, theological, or contextual reasons. " \
        "Reflect the historical and linguistic context only, avoiding doctrinal interpretation. " \
        "Mark elements with no direct English equivalent, and note ambiguities without resolving them."
    },
    "easy_read" => {
      abbreviation_suffix: "EZ",
      name_suffix: "Easy Read",
      instruction: "Produce an accessible modern prose rendering. " \
        "Reflect the same authorial intent from a historical and secular standpoint. " \
        "Write for a general audience without devotional framing. Use natural, contemporary English."
    },
    "summary" => {
      abbreviation_suffix: "SUM",
      name_suffix: "Summary",
      instruction: "Produce a condensed paraphrase of the passage. " \
        "Reflect the same authorial intent from a historical and secular standpoint. " \
        "Write for a general audience without devotional framing. Brevity is key."
    }
  }.freeze

  PROVIDERS = {
    "claude" => { name: "Claude", class_name: "Llm::Anthropic" },
    "chatgpt" => { name: "ChatGPT", class_name: "Llm::Openai" }
  }.freeze

  DEFAULT_PROVIDER = "chatgpt"

  def perform(passage_id:, style:, provider: DEFAULT_PROVIDER, source_translation_id: nil)
    passage = Passage.find(passage_id)
    style_config = STYLES.fetch(style)
    provider_config = PROVIDERS.fetch(provider, PROVIDERS[DEFAULT_PROVIDER])
    scripture = passage.scripture
    corpus = scripture.corpus

    # Find original language text or fall back to specified translation
    source_text = if source_translation_id
      passage.text_for(Translation.find(source_translation_id))
    else
      passage.passage_translations
        .joins(:translation).where(translations: { edition_type: "original" })
        .first&.text
    end

    return unless source_text.present?

    source_translation = passage.translations.find_by(edition_type: "original") ||
      Translation.find(source_translation_id)

    # Build LLM translation
    translation = Translation.find_or_create_by!(
      abbreviation: "LLM-#{style_config[:abbreviation_suffix]}",
      corpus: corpus
    ) do |t|
      t.name = "AI #{style_config[:name_suffix]}"
      t.language = "English"
      t.edition_type = "critical"
      t.description = "AI-generated translation using #{style} mode."
    end

    prompt = build_prompt(passage, scripture, source_text, source_translation, style_config)
    generated_text = provider_config[:class_name].constantize.new.call(prompt)

    return unless generated_text.present?

    pt = PassageTranslation.find_or_create_by!(passage: passage, translation: translation) do |record|
      record.text = generated_text
    end

    broadcast_translation(passage, pt.text)
  end

  private

  def build_prompt(passage, scripture, source_text, source_translation, style_config)
    <<~PROMPT
      You are a secular, historically-informed scripture translator. You are translating from #{source_translation.language} to English.

      Original text (#{source_translation.language}):
      #{source_text}

      #{style_config[:instruction]}

      Respond with ONLY the translated text. No commentary, no verse numbers, no labels.
    PROMPT
  end

  def broadcast_translation(passage, text)
    division = passage.division
    stream_name = "llm_translations_#{division.id}"
    escaped = ERB::Util.html_escape(text)

    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name,
      target: "passage_#{passage.id}_translation",
      html: <<~HTML
        <textarea name="text"
                  rows="3"
                  class="w-full text-sm rounded-md border border-emerald-300 dark:border-emerald-600 bg-emerald-50 dark:bg-emerald-900/20 text-slate-700 dark:text-slate-300 px-3 py-2 leading-relaxed resize-y focus:ring-1 focus:ring-blue-500 focus:border-blue-500">#{escaped}</textarea>
      HTML
    )
  end
end
