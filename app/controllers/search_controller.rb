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
    return PassageTranslation.none if @query.blank?

    tsquery = sanitize_tsquery(@query)
    rank_sql = ActiveRecord::Base.sanitize_sql_array(
      [ "ts_rank(search_vector, to_tsquery('simple', ?)) DESC", tsquery ]
    )
    scope = PassageTranslation
      .where("search_vector @@ to_tsquery('simple', ?)", tsquery)
      .includes(passage: { division: { scripture: { corpus: :tradition } } }, translation: {})
      .order(Arel.sql(rank_sql))

    scope = apply_scope_filter(scope)
    @total = scope.size
    scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def concordance_search
    return PassageTranslation.none if @query.blank?

    tsquery = sanitize_tsquery(@query)
    scope = PassageTranslation
      .where("search_vector @@ to_tsquery('simple', ?)", tsquery)
      .includes(passage: { division: { scripture: { corpus: :tradition } } }, translation: {})
      .order("passage_translations.id")

    scope = apply_scope_filter(scope)
    scope = scope.where(translations: { abbreviation: params[:translation] }) if params[:translation].present?
    @total = scope.count
    scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def lemma_search
    return OriginalLanguageToken.none if @query.blank?

    scope = OriginalLanguageToken
      .includes(:lexicon_entry, passage: { division: { scripture: { corpus: :tradition } } })

    if @query.match?(/\AH\d+\z/i) || @query.match?(/\AG\d+\z/i)
      # Strong's number search
      entry = LexiconEntry.find_by(strongs_number: @query.upcase)
      scope = entry ? scope.where(lexicon_entry: entry) : scope.none
    else
      # Lemma text search
      scope = scope.where("lemma = ? OR lemma LIKE ?", @query, "#{@query}%")
    end

    @total = scope.count
    scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def apply_scope_filter(scope)
    case @scope
    when "tradition"
      scope.joins(passage: { division: { scripture: { corpus: :tradition } } })
        .where(traditions: { slug: params[:tradition_slug] }) if params[:tradition_slug].present?
    when "corpus"
      scope.joins(passage: { division: { scripture: :corpus } })
        .where(corpora: { slug: params[:corpus_slug] }) if params[:corpus_slug].present?
    when "annotations"
      if current_user
        scope.joins(passage: :annotations)
          .where(annotations: { user_id: current_user.id })
      else
        scope.none
      end
    else
      scope
    end || scope
  end

  def sanitize_tsquery(query)
    # Split into words, join with & for AND semantics, escape special chars
    words = query.gsub(/[^a-zA-Z0-9\u0590-\u05FF\u0600-\u06FF\u0370-\u03FF\s]/, "").split(/\s+/).reject(&:blank?)
    words.map { |w| ActiveRecord::Base.connection.quote_string(w) }.join(" & ")
  end
end
