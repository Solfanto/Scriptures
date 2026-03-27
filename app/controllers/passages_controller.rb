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

    # Selected translations from params or defaults
    @selected_translations = resolve_translations

    # Navigation
    all_divisions = @scripture.divisions.reorder(:position)
    current_index = all_divisions.index(@division)
    @prev_division = current_index&.positive? ? all_divisions[current_index - 1] : nil
    @next_division = current_index && current_index < all_divisions.size - 1 ? all_divisions[current_index + 1] : nil

    # User organization data
    if current_user
      passage_ids = @passages.map(&:id)
      @bookmarked_ids = current_user.bookmarks.where(passage_id: passage_ids).pluck(:passage_id).to_set
      @user_annotations = current_user.annotations.where(passage_id: passage_ids).group_by(&:passage_id)
      @user_collections = current_user.collections
    else
      @bookmarked_ids = Set.new
      @user_annotations = {}
      @user_collections = Collection.none
    end

    # For parallel view
    @parallel = params[:parallel].present?

    # For diff view
    if params[:diff].present? && @selected_translations.size >= 2
      @diff_left = @selected_translations[0]
      @diff_right = @selected_translations[1]
    end
  end

  def jump
    ref = params[:ref].to_s.strip
    passage = resolve_reference(ref)

    if passage
      division = passage.division
      scripture = division.scripture
      corpus = scripture.corpus
      redirect_to reading_path(corpus_slug: corpus.slug, scripture_slug: scripture.slug, division_number: division.number)
    else
      redirect_back fallback_location: root_path, alert: "Could not find \"#{ref}\"."
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

  def resolve_reference(ref)
    # Parse references like "Genesis 1:1", "John 3:16", "Gen 1:1"
    match = ref.match(/\A(.+?)\s+(\d+):(\d+)\z/)
    return nil unless match

    book_query, chapter, verse = match[1], match[2].to_i, match[3].to_i

    scripture = Scripture.where("name LIKE ? OR slug LIKE ?", "#{book_query}%", "#{book_query.downcase}%").first
    return nil unless scripture

    division = scripture.divisions.find_by(number: chapter)
    return nil unless division

    division.passages.find_by(number: verse)
  end
end
