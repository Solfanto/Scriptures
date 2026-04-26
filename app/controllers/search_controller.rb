class SearchController < ApplicationController
  PER_PAGE = 25

  def index
    @query = params[:q].to_s.strip
    @scope = params[:scope]
    @page = [ params[:page].to_i, 1 ].max
    @mode = params[:mode] # "concordance" or "lemma"

    @results = case @mode
    when "concordance" then concordance_search
    when "lemma" then lemma_search
    else fulltext_search
    end
  end

  private

  def fulltext_search
    return TranslationSegment.none if @query.blank?

    rank_sql = ActiveRecord::Base.sanitize_sql_array(
      [ "ts_rank(search_vector, websearch_to_tsquery('simple', ?)) DESC", @query ]
    )
    scope = TranslationSegment
      .where("search_vector @@ websearch_to_tsquery('simple', ?)", @query)
      .includes(start_passage: { division: { scripture: { corpus: :tradition } } }, translation: {})
      .order(Arel.sql(rank_sql))

    scope = apply_scope_filter(scope)
    @total = scope.count(:all)
    scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def concordance_search
    return TranslationSegment.none if @query.blank?

    scope = TranslationSegment
      .where("search_vector @@ websearch_to_tsquery('simple', ?)", @query)
      .includes(start_passage: { division: { scripture: { corpus: :tradition } } }, translation: {})
      .order("translation_segments.id")

    scope = apply_scope_filter(scope)
    scope = scope.where(translations: { abbreviation: params[:translation] }) if params[:translation].present?
    @total = scope.count(:all)
    scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def lemma_search
    return OriginalLanguageToken.none if @query.blank?

    scope = OriginalLanguageToken
      .includes(:lexicon_entry, passage: { division: { scripture: { corpus: :tradition } } })

    if @query.match?(/\AH\d+\z/i) || @query.match?(/\AG\d+\z/i)
      entry = LexiconEntry.find_by(strongs_number: @query.upcase)
      scope = entry ? scope.where(lexicon_entry: entry) : scope.none
    else
      scope = scope.where("lemma = ? OR lemma LIKE ?", @query, "#{ActiveRecord::Base.sanitize_sql_like(@query)}%")
    end

    @total = scope.count(:all)
    scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def apply_scope_filter(scope)
    case @scope
    when "tradition"
      scope.joins(start_passage: { division: { scripture: { corpus: :tradition } } })
        .where(traditions: { slug: params[:tradition_slug] }) if params[:tradition_slug].present?
    when "corpus"
      scope.joins(start_passage: { division: { scripture: :corpus } })
        .where(corpora: { slug: params[:corpus_slug] }) if params[:corpus_slug].present?
    when "annotations"
      if current_user
        scope.joins(start_passage: :annotations)
          .where(annotations: { user_id: current_user.id })
      else
        scope.none
      end
    else
      scope
    end || scope
  end
end
