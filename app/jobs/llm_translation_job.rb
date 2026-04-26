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

  def perform(start_passage_id:, end_passage_id:, style:, provider: DEFAULT_PROVIDER, source_translation_id: nil)
    start_passage = Passage.find(start_passage_id)
    end_passage = Passage.find(end_passage_id)
    style_config = STYLES.fetch(style)
    provider_config = PROVIDERS.fetch(provider, PROVIDERS[DEFAULT_PROVIDER])
    scripture = start_passage.scripture
    corpus = scripture.corpus

    source_translation = if source_translation_id
      Translation.find(source_translation_id)
    else
      corpus.translations.find_by(edition_type: "original")
    end

    return unless source_translation

    source_text = collect_source_text(start_passage, end_passage, source_translation)
    return unless source_text.present?

    translation = Translation.find_or_create_by!(
      abbreviation: "LLM-#{style_config[:abbreviation_suffix]}",
      corpus: corpus
    ) do |t|
      t.name = "AI #{style_config[:name_suffix]}"
      t.language = "English"
      t.edition_type = "critical"
      t.description = "AI-generated translation using #{style} mode."
    end

    prompt = build_prompt(scripture, source_text, source_translation, style_config)
    generated_text = provider_config[:class_name].constantize.new.call(prompt)

    return unless generated_text.present?

    segment = TranslationSegment.upsert_for_range(
      translation: translation,
      start_passage: start_passage,
      end_passage: end_passage,
      text: generated_text
    )

    broadcast_translation(start_passage.division, segment)
  end

  private

  def collect_source_text(start_passage, end_passage, source_translation)
    scripture = start_passage.scripture
    passages = Passage
      .where(division_id: scripture.divisions.select(:id))
      .where("position_in_scripture BETWEEN ? AND ?",
             start_passage.position_in_scripture, end_passage.position_in_scripture)
      .order(:position_in_scripture)
    passages.map { |p| p.text_for(source_translation) }.compact.reject(&:blank?).join("\n")
  end

  def build_prompt(scripture, source_text, source_translation, style_config)
    <<~PROMPT
      You are a secular, historically-informed scripture translator. You are translating from #{source_translation.language} to English.

      Original text (#{source_translation.language}):
      #{source_text}

      #{style_config[:instruction]}

      Respond with ONLY the translated text. No commentary, no verse numbers, no labels.
    PROMPT
  end

  def broadcast_translation(division, segment)
    stream_name = "llm_translations_#{division.id}"
    target = "translation_segment_#{segment.start_passage_id}_#{segment.end_passage_id}_textarea"
    escaped = ERB::Util.html_escape(segment.text)

    Turbo::StreamsChannel.broadcast_replace_to(
      stream_name,
      target: target,
      html: <<~HTML
        <textarea id="#{target}" name="text"
                  rows="3"
                  class="w-full text-sm rounded-md border border-emerald-300 dark:border-emerald-600 bg-emerald-50 dark:bg-emerald-900/20 text-slate-700 dark:text-slate-300 px-3 py-2 leading-relaxed resize-y focus:ring-1 focus:ring-blue-500 focus:border-blue-500">#{escaped}</textarea>
      HTML
    )
  end
end
