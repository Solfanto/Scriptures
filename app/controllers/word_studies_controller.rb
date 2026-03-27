class WordStudiesController < ApplicationController
  def show
    token = OriginalLanguageToken.includes(:lexicon_entry).find_by(
      passage_id: params[:passage_id],
      position: params[:position]
    )

    if token
      entry = token.lexicon_entry
      concordance_count = entry ? OriginalLanguageToken.where(lexicon_entry: entry).count : 0

      render json: {
        text: token.text,
        transliteration: token.transliteration,
        lemma: token.lemma,
        morphology: token.morphology,
        definition: entry&.definition,
        strongs_number: entry&.strongs_number,
        morphology_label: entry&.morphology_label,
        language: entry&.language,
        concordance_count: concordance_count
      }
    else
      render json: { text: params[:word], message: "No lexicon data available" }
    end
  end

  def concordance
    entry = LexiconEntry.find(params[:id])
    tokens = entry.original_language_tokens
      .includes(passage: { division: { scripture: :corpus } })
      .limit(100)

    results = tokens.map do |token|
      passage = token.passage
      scripture = passage.scripture
      {
        reference: "#{scripture.name} #{passage.division.number}:#{passage.number}",
        corpus_slug: scripture.corpus.slug,
        scripture_slug: scripture.slug,
        division_number: passage.division.number,
        text: token.text,
        context: passage.passage_translations.first&.text&.truncate(120)
      }
    end

    render json: { lemma: entry.lemma, language: entry.language, count: entry.original_language_tokens.count, results: results }
  end
end
