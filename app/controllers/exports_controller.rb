class ExportsController < ApplicationController
  require_authentication except: %i[passages collection]

  def passages
    @corpus = Corpus.find_by!(slug: params[:corpus_slug])
    @scripture = @corpus.scriptures.find_by!(slug: params[:scripture_slug])

    from_chapter = params[:from_chapter].to_i
    to_chapter = params[:to_chapter].presence&.to_i || from_chapter

    @divisions = @scripture.divisions
      .where(number: from_chapter..to_chapter)
      .includes(passages: [ :source_documents, :commentaries ])
      .order(:position)

    @translations = resolve_export_translations
    Passage.preload_texts!(@divisions.flat_map(&:passages), @translations.to_a)
    options = export_options

    respond_to do |format|
      format.pdf do
        pdf = PassagePdfRenderer.new(@scripture, @divisions, @translations, options).render
        send_data pdf, filename: pdf_filename, type: "application/pdf", disposition: "inline"
      end
    end
  end

  def collection
    @collection = Collection.find(params[:id])
    unless @collection.public? || (authenticated? && @collection.user == current_user)
      redirect_to root_path, alert: "Collection not found."
      return
    end

    items = @collection.collection_passages.includes(
      passage: [ :source_documents, :commentaries, { division: { scripture: :corpus } } ]
    )

    options = export_options

    respond_to do |format|
      format.pdf do
        pdf = CollectionPdfRenderer.new(@collection, items, options).render
        send_data pdf, filename: "#{@collection.name.parameterize}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  private

  def resolve_export_translations
    if params[:t].present?
      abbrs = Array(params[:t])
      @corpus.translations.where(abbreviation: abbrs)
    else
      @corpus.translations.limit(2)
    end
  end

  def export_options
    {
      annotations: params[:annotations] == "1" && authenticated?,
      highlights: params[:highlights] == "1" && authenticated?,
      commentary: params[:commentary] == "1",
      parallel: params[:parallel] == "1",
      sources: params[:sources] == "1",
      user: current_user
    }
  end

  def pdf_filename
    from = params[:from_chapter]
    to = params[:to_chapter].presence || from
    range = from == to ? "ch#{from}" : "ch#{from}-#{to}"
    "#{@scripture.name.parameterize}-#{range}.pdf"
  end
end
