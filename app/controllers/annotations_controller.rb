class AnnotationsController < ApplicationController
  require_authentication except: %i[index public_set]

  def index
    if params[:user_id] && authenticated?
      @annotations = current_user.annotations.includes(passage: { division: { scripture: :corpus } }, tags: [])
      @annotations = @annotations.joins(:tags).where(tags: { name: params[:tag] }) if params[:tag].present?
    else
      @annotations = Annotation.none
    end

    if params[:q].present?
      @annotations = @annotations.where("body LIKE ?", "%#{Annotation.sanitize_sql_like(params[:q])}%")
    end

    @tags = current_user&.tags || Tag.none
  end

  def public_set
    @user = User.find(params[:user_id])
    @annotations = @user.annotations.publicly_visible.includes(passage: { division: { scripture: :corpus } }, tags: [])
    @annotations = @annotations.joins(:tags).where(tags: { name: params[:tag] }) if params[:tag].present?
    @tags = Tag.joins(:annotations).where(annotations: { user_id: @user.id, public: true }).distinct
  end

  def create
    @annotation = current_user.annotations.new(annotation_params)
    @annotation.tag_list = params[:annotation][:tag_list] if params.dig(:annotation, :tag_list)

    if @annotation.save
      redirect_back fallback_location: root_path, notice: "Annotation saved."
    else
      redirect_back fallback_location: root_path, alert: @annotation.errors.full_messages.join(", ")
    end
  end

  def update
    @annotation = current_user.annotations.find(params[:id])
    @annotation.assign_attributes(annotation_params)
    @annotation.tag_list = params[:annotation][:tag_list] if params.dig(:annotation, :tag_list)

    if @annotation.save
      redirect_back fallback_location: annotations_path(user_id: current_user), notice: "Annotation updated."
    else
      redirect_back fallback_location: root_path, alert: @annotation.errors.full_messages.join(", ")
    end
  end

  def destroy
    current_user.annotations.find(params[:id]).destroy
    redirect_back fallback_location: annotations_path(user_id: current_user)
  end

  def export
    annotations = current_user.annotations.includes(passage: { division: { scripture: :corpus } }, tags: [])

    respond_to do |format|
      format.json do
        data = annotations.map { |a| annotation_to_hash(a) }
        send_data data.to_json, filename: "annotations-#{Date.current}.json", type: "application/json"
      end
      format.csv do
        csv = generate_csv(annotations)
        send_data csv, filename: "annotations-#{Date.current}.csv", type: "text/csv"
      end
    end
  end

  def import
    file = params[:file]
    unless file&.content_type&.in?(%w[application/json])
      redirect_to annotations_path(user_id: current_user), alert: "Please upload a JSON file."
      return
    end

    data = JSON.parse(file.read)
    imported = 0
    skipped = 0

    data.each do |entry|
      passage = find_passage_from_ref(entry)
      next unless passage

      existing = current_user.annotations.find_by(passage: passage, body: entry["body"])
      if existing
        skipped += 1
        next
      end

      annotation = current_user.annotations.new(
        passage: passage,
        body: entry["body"],
        public: entry["public"] || false
      )
      annotation.tag_list = Array(entry["tags"]).join(", ") if entry["tags"].present?
      if annotation.save
        imported += 1
      else
        skipped += 1
      end
    end

    redirect_to annotations_path(user_id: current_user),
      notice: "Imported #{imported} annotation#{'s' unless imported == 1}. Skipped #{skipped} duplicate#{'s' unless skipped == 1}."
  rescue JSON::ParserError
    redirect_to annotations_path(user_id: current_user), alert: "Invalid JSON file."
  end

  private

  def annotation_params
    params.require(:annotation).permit(:passage_id, :body, :public)
  end

  def annotation_to_hash(annotation)
    passage = annotation.passage
    scripture = passage.division.scripture
    corpus = scripture.corpus
    {
      corpus: corpus.slug,
      scripture: scripture.slug,
      chapter: passage.division.number,
      verse: passage.number,
      reference: "#{scripture.name} #{passage.division.number}:#{passage.number}",
      body: annotation.body,
      tags: annotation.tags.pluck(:name),
      public: annotation.public?,
      created_at: annotation.created_at.iso8601
    }
  end

  def generate_csv(annotations)
    require "csv"
    CSV.generate do |csv|
      csv << %w[Reference Corpus Scripture Chapter Verse Body Tags Public Created]
      annotations.each do |a|
        passage = a.passage
        scripture = passage.division.scripture
        corpus = scripture.corpus
        csv << [
          "#{scripture.name} #{passage.division.number}:#{passage.number}",
          corpus.slug,
          scripture.slug,
          passage.division.number,
          passage.number,
          a.body,
          a.tags.pluck(:name).join("; "),
          a.public?,
          a.created_at.iso8601
        ]
      end
    end
  end

  def find_passage_from_ref(entry)
    corpus = Corpus.find_by(slug: entry["corpus"])
    return nil unless corpus

    scripture = corpus.scriptures.find_by(slug: entry["scripture"])
    return nil unless scripture

    division = scripture.divisions.find_by(number: entry["chapter"])
    return nil unless division

    division.passages.find_by(number: entry["verse"])
  end
end
