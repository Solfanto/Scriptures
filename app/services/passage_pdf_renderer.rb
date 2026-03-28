class PassagePdfRenderer
  def initialize(scripture, divisions, translations, options = {})
    @scripture = scripture
    @divisions = divisions
    @translations = translations
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
    pdf.font_size(20) { pdf.text @scripture.name, style: :bold }
    pdf.move_down 5
    pdf.font_size(10) do
      pdf.text "#{@scripture.corpus.name} — #{@translations.map(&:abbreviation).join(', ')}", color: "666666"
    end
    pdf.move_down 20

    @divisions.each do |division|
      # Chapter heading
      pdf.font_size(14) { pdf.text "Chapter #{division.number}", style: :bold }
      pdf.move_down 10

      division.passages.each do |passage|
        render_passage(pdf, passage)
      end

      pdf.move_down 15
    end

    pdf.render
  end

  private

  def render_passage(pdf, passage)
    if @options[:parallel] && @translations.size > 1
      render_parallel_passage(pdf, passage)
    else
      render_standard_passage(pdf, passage)
    end

    render_source_attribution(pdf, passage) if @options[:sources]
    render_commentary(pdf, passage) if @options[:commentary]
    render_annotations(pdf, passage) if @options[:annotations]

    pdf.move_down 8
  end

  def render_standard_passage(pdf, passage)
    @translations.each_with_index do |t, i|
      text = passage.text_for(t)
      next unless text

      if i == 0
        pdf.text "<b>#{passage.number}</b> #{text}", inline_format: true, size: 11, leading: 4
      else
        pdf.indent(20) do
          pdf.text "[#{t.abbreviation}] #{text}", size: 9, color: "555555", leading: 3
        end
      end
    end
  end

  def render_parallel_passage(pdf, passage)
    data = @translations.map do |t|
      text = passage.text_for(t)
      ["#{t.abbreviation}\n#{text || '—'}"]
    end

    if data.any?
      verse_label = [["#{passage.number}"]]
      table_data = [data.map { |d| d[0] }]

      pdf.font_size(9) do
        pdf.text "<b>#{passage.number}</b>", inline_format: true, size: 10
        pdf.indent(15) do
          table_data.first.each_with_index do |cell, i|
            pdf.text "<b>#{@translations[i].abbreviation}</b>: #{cell.sub(/\A#{@translations[i].abbreviation}\n/, '')}", inline_format: true, leading: 3
            pdf.move_down 2
          end
        end
      end
    end
  end

  def render_source_attribution(pdf, passage)
    sources = passage.source_documents
    return if sources.empty?

    pdf.indent(20) do
      sources.each do |sd|
        pdf.text "Source: #{sd.name} (#{sd.abbreviation})", size: 8, color: "888888"
      end
    end
  end

  def render_commentary(pdf, passage)
    comments = passage.commentaries
    return if comments.empty?

    pdf.indent(20) do
      comments.each do |c|
        pdf.text "[#{c.commentary_type.capitalize}] #{c.body}", size: 8, color: "666666", leading: 2
        pdf.text "— #{c.author}", size: 7, color: "999999" if c.author.present?
        pdf.move_down 3
      end
    end
  end

  def render_annotations(pdf, passage)
    user = @options[:user]
    return unless user

    annotations = user.annotations.where(passage: passage)
    return if annotations.empty?

    pdf.indent(20) do
      pdf.stroke_color "4488CC"
      pdf.stroke { pdf.horizontal_rule }
      pdf.move_down 3
      annotations.each do |ann|
        pdf.text "Note: #{ann.body}", size: 8, color: "336699", leading: 2
        if ann.tags.any?
          pdf.text "Tags: #{ann.tag_list}", size: 7, color: "999999"
        end
        pdf.move_down 2
      end
      pdf.stroke_color "000000"
    end
  end
end
