class ConcordancesController < ApplicationController
  def show
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
        context: passage.covering_segments.first&.text&.truncate(120)
      }
    end

    render json: { lemma: entry.lemma, language: entry.language, count: entry.original_language_tokens.count, results: results }
  end
end
