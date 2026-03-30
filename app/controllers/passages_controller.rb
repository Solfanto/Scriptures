class PassagesController < ApplicationController
  def show
    if params[:corpus_slug]
      @corpus = Corpus.find_by!(slug: params[:corpus_slug])
      @scripture = @corpus.scriptures.find_by!(slug: params[:scripture_slug])
      @division = @scripture.divisions.find_by!(number: params[:division_number])
    else
      # Default: Genesis 1
      @corpus = Corpus.find_by!(slug: "bible")
      @scripture = @corpus.scriptures.find_by!(slug: "genesis")
      @division = @scripture.divisions.find_by!(number: 1)
    end

    @tradition = @corpus.tradition
    @passages = @division.passages.includes(
      :passage_translations, :translations, :source_documents,
      :textual_variants, :original_language_tokens, :commentaries,
      parallel_passages: { parallel_passage: { division: { scripture: :corpus } } }
    )
    @translations = @corpus.translations.order(:language, :name)
    @source_documents = @corpus.source_documents

    @selected_translations = resolve_translations

    all_divisions = @scripture.divisions.reorder(:position)
    current_index = all_divisions.index(@division)
    @prev_division = current_index&.positive? ? all_divisions[current_index - 1] : nil
    @next_division = current_index && current_index < all_divisions.size - 1 ? all_divisions[current_index + 1] : nil

    if current_user
      passage_ids = @passages.map(&:id)
      @bookmarked_ids = current_user.bookmarks.where(passage_id: passage_ids).pluck(:passage_id).to_set
      @user_annotations = current_user.annotations.where(passage_id: passage_ids).group_by(&:passage_id)
      @user_collections = current_user.collections
      @user_curricula = current_user.curricula
      @read_passage_ids = current_user.reading_progresses.where(passage_id: passage_ids).pluck(:passage_id).to_set
    else
      @bookmarked_ids = Set.new
      @user_annotations = {}
      @user_collections = Collection.none
      @user_curricula = Curriculum.none
      @read_passage_ids = Set.new
    end

    session[:last_reading] = reading_path(corpus_slug: @corpus.slug, scripture_slug: @scripture.slug, division_number: @division.number)

    @parallel = params[:parallel].present?

    if params[:diff].present? && @selected_translations.size >= 2
      @diff_left = @selected_translations[0]
      @diff_right = @selected_translations[1]
    end

    # HTTP caching for unauthenticated visitors
    unless current_user
      expires_in 1.hour, public: true
      fresh_when etag: cache_key, last_modified: @division.updated_at
    end
  end

  private

  def resolve_translations
    if params[:t].present?
      abbrs = Array(params[:t])
      @translations.where(abbreviation: abbrs).presence || default_translations
    else
      default_translations
    end
  end

  def default_translations
    primary = @translations.find_by(language: "Hebrew") || @translations.first
    secondary = @translations.find_by(abbreviation: "KJV") || @translations.second
    [ primary, secondary ].compact.uniq
  end

  def cache_key
    [ @division.id, @division.updated_at, params[:t], params[:parallel], params[:diff] ]
  end
end
