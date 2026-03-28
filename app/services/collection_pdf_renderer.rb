class CollectionPdfRenderer
  def initialize(collection, items, options = {})
    @collection = collection
    @items = items
    @options = options
  end

  FONT_DIR = Rails.root.join("app/assets/fonts")

  def render
    pdf = Prawn::Document.new(page_size: "A4", margin: [50, 50, 50, 50])
    pdf.font_families.update("DejaVu" => {
      normal: FONT_DIR.join("DejaVuSans.ttf").to_s,
      bold: FONT_DIR.join("DejaVuSans-Bold.ttf").to_s
    })
    pdf.font "DejaVu"

    # Title
    pdf.font_size(20) { pdf.text @collection.name, style: :bold }
    if @collection.description.present?
      pdf.move_down 5
      pdf.font_size(10) { pdf.text @collection.description, color: "666666" }
    end
    pdf.move_down 5
    pdf.font_size(9) { pdf.text "#{@items.size} passages", color: "999999" }
    pdf.move_down 20

    @items.each do |cp|
      passage = cp.passage
      scripture = passage.division.scripture
      corpus = scripture.corpus
      ref = "#{scripture.name} #{passage.division.number}:#{passage.number}"

      # Reference heading
      pdf.font_size(11) { pdf.text ref, style: :bold }
      pdf.font_size(8) { pdf.text corpus.name, color: "999999" }
      pdf.move_down 3

      # Passage text (first available translation)
      translation = corpus.translations.first
      if translation
        text = passage.text_for(translation)
        if text
          pdf.text text, size: 10, leading: 4
          pdf.font_size(8) { pdf.text "— #{translation.abbreviation}", color: "888888" }
        end
      end

      # Optional: commentary
      if @options[:commentary]
        passage.commentaries.each do |c|
          pdf.indent(15) do
            pdf.text "[#{c.commentary_type.capitalize}] #{c.body}", size: 8, color: "666666", leading: 2
          end
        end
      end

      # Optional: annotations
      if @options[:annotations] && @options[:user]
        @options[:user].annotations.where(passage: passage).each do |ann|
          pdf.indent(15) do
            pdf.text "Note: #{ann.body}", size: 8, color: "336699", leading: 2
          end
        end
      end

      pdf.move_down 12
    end

    pdf.render
  end
end
