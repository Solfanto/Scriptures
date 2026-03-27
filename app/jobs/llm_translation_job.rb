class LlmTranslationJob < ApplicationJob
  queue_as :default

  STYLES = {
    "word_for_word" => {
      abbreviation_suffix: "WFW",
      name_suffix: "Word-for-word",
      instruction: "Produce a precise word-for-word rendering from the original language. " \
        "Reflect what the original authors meant from a historical and secular standpoint. " \
        "Avoid theological interpretation. Preserve the grammatical structure of the original as closely as possible."
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

  def perform(passage_id:, style:, source_translation_id: nil)
    passage = Passage.find(passage_id)
    style_config = STYLES.fetch(style)
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
    generated_text = call_llm(prompt)

    return unless generated_text.present?

    PassageTranslation.find_or_create_by!(passage: passage, translation: translation) do |pt|
      pt.text = generated_text
    end
  end

  private

  def build_prompt(passage, scripture, source_text, source_translation, style_config)
    <<~PROMPT
      You are a secular, historically-informed scripture translator. You are translating from #{source_translation.language} to English.

      Context: #{scripture.name} #{passage.division.number}:#{passage.number} (#{scripture.corpus.name})

      Original text (#{source_translation.language}):
      #{source_text}

      #{style_config[:instruction]}

      Respond with ONLY the translated text. No commentary, no verse numbers, no labels.
    PROMPT
  end

  def call_llm(prompt)
    api_key = Rails.application.credentials.dig(:anthropic, :api_key) || ENV["ANTHROPIC_API_KEY"]
    return nil unless api_key

    require "net/http"
    require "json"

    uri = URI("https://api.anthropic.com/v1/messages")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = api_key
    request["anthropic-version"] = "2023-06-01"
    request.body = {
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
      messages: [ { role: "user", content: prompt } ]
    }.to_json

    response = http.request(request)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    data.dig("content", 0, "text")&.strip
  end
end
