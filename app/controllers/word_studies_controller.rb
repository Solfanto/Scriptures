class WordStudiesController < ApplicationController
  def show
    token = OriginalLanguageToken.includes(:lexicon_entry).find_by(
      passage_id: params[:passage_id],
      position: params[:position]
    )

    if token
      entry = token.lexicon_entry
      concordance_count = entry ? OriginalLanguageToken.where(lexicon_entry: entry).count : 0
      translation_renderings = entry ? build_translation_renderings(entry) : {}

      render json: {
        text: token.text,
        transliteration: token.transliteration,
        lemma: token.lemma,
        morphology: token.morphology,
        definition: entry&.definition,
        strongs_number: entry&.strongs_number,
        morphology_label: entry&.morphology_label,
        language: entry&.language,
        concordance_count: concordance_count,
        most_common_rendering: translation_renderings[:most_common],
        other_renderings: translation_renderings[:others]
      }
    else
      render json: { text: params[:word], message: "No lexicon data available" }
    end
  end

  private

  # For a given lexicon entry, find how the corresponding word position is
  # rendered across English translations. Returns { most_common:, others: [] }.
  def build_translation_renderings(entry)
    # Sample up to 50 passages that contain this lemma
    sample_tokens = entry.original_language_tokens.includes(passage: { division: :scripture }).limit(50)

    word_counts = Hash.new(0)

    sample_tokens.each do |tok|
      tok.passage.covering_segments.each do |segment|
        words = segment.text.split(/\s+/)
        # Approximate: grab the word at the same relative position
        idx = tok.position - 1
        word = words[idx] || words.last
        next unless word
        cleaned = word.downcase.gsub(/[^a-z']/, "")
        next if cleaned.blank?
        word_counts[cleaned] += 1
      end
    end

    return {} if word_counts.empty?

    sorted = word_counts.sort_by { |_, count| -count }
    most_common = sorted.first
    others = sorted[1..4]&.map(&:first) || []

    { most_common: "#{most_common[0]} (#{most_common[1]}x)", others: others }
  end
end
