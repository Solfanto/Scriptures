module Import
  class LeborGabala
    # Imports Lebor Gabála Érenn (Book of Invasions) from Macalister's critical edition.
    #
    # Source: R.A.S. Macalister (ed.), Lebor Gabála Érenn, Irish Texts Society,
    # 5 vols. (1938–1956). Internet Archive DjVu OCR text.
    #
    # The printed edition has Irish text on even (verso) pages and English
    # translation on odd (recto) pages, with critical apparatus between them.
    # This importer extracts only the original Old/Middle Irish text, which
    # is public domain as a medieval manuscript text.
    #
    # Mapping:
    #   Tradition "Celtic" → Corpus "Celtic Literature"
    #   → Scripture "Lebor Gabála Érenn"
    #   → Division (one per volume/part) → Passage (one per numbered paragraph)
    #   → PassageTranslation (Old/Middle Irish)

    # Common English function words for language detection.
    # If >15% of a paragraph's words are English function words, skip it.
    ENGLISH_STOP_WORDS = Set.new(%w[
      the of and he she it was were is are his her that which with from
      for but had have has they who said unto made there this upon into
      over shall been when where some more after also than not their them
      all would could should did does will may might any other these those
      every each then because before such only through about what how its
      between being both came down even first gave great himself most our
      own same still very went your against came every much under well
    ]).freeze

    VOLUME_TITLES = {
      1 => "From the Creation to the Dispersal of the Nations",
      2 => "The Invasion of Cessair and the Invasion of Partholón",
      3 => "The Invasion of Nemed and the Fir Bolg",
      4 => "The Tuatha Dé Danann and the Sons of Míl",
      5 => "The Roll of the Kings"
    }.freeze

    def initialize(files:, progress: nil)
      @files = files.map { |f| Pathname.new(f) }
      @progress = progress
    end

    def run
      ensure_tradition_and_corpus

      scripture = Scripture.find_or_create_by!(corpus: @corpus, slug: "lebor-gabala-erenn") do |s|
        s.name = "Lebor Gabála Érenn"
        s.position = Scripture.where(corpus: @corpus).count + 1
        s.description = "The Book of the Taking of Ireland, a pseudo-historical compilation " \
                        "narrating the successive invasions of Ireland from the Creation to the Gaels. " \
                        "Compiled in the 11th century from earlier sources, preserved in multiple recensions."
      end

      translation = ensure_translation

      total_paragraphs = 0
      done = 0

      # First pass: count paragraphs for progress reporting
      volumes = @files.each_with_index.map do |file, idx|
        volume_number = idx + 1
        next unless file.exist?

        raw = File.read(file, encoding: "UTF-8")
        raw.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")
        paragraphs = extract_irish_paragraphs(raw)
        total_paragraphs += paragraphs.size
        { number: volume_number, paragraphs: paragraphs }
      end.compact

      @progress&.call(0, total_paragraphs)

      volumes.each do |volume|
        title = VOLUME_TITLES[volume[:number]] || "Part #{volume[:number]}"
        division = Division.find_or_create_by!(scripture: scripture, number: volume[:number]) do |d|
          d.name = title
          d.position = volume[:number]
        end

        volume[:paragraphs].each_with_index do |para_text, idx|
          passage_number = idx + 1
          passage = Passage.find_or_create_by!(division: division, number: passage_number) do |p|
            p.position = passage_number
          end

          PassageTranslation.find_or_create_by!(passage: passage, translation: translation) do |pt|
            pt.text = para_text
          end

          done += 1
          @progress&.call(done, total_paragraphs) if done % 50 == 0
        end
      end

      @progress&.call(total_paragraphs, total_paragraphs)
      puts "  Lebor Gabála Érenn: #{done} passages across #{volumes.size} volumes"
    end

    private

    def extract_irish_paragraphs(raw)
      lines = raw.lines.map(&:rstrip)

      # Skip front matter: find first numbered paragraph
      text_start = lines.index { |l| l.strip.match?(/\A\d{1,3}[*.]*\.\s/) && !page_header?(l) }
      return [] unless text_start

      lines = lines[text_start..]

      # Collect numbered paragraphs
      paragraphs = []
      current = nil

      lines.each do |line|
        stripped = line.strip
        next if stripped.empty?
        next if page_header?(stripped)
        next if apparatus_line?(stripped)

        if numbered_paragraph_start?(stripped)
          if current
            paragraphs << current unless english_text?(current)
          end
          current = stripped.sub(/\A\d{1,3}[*.]*\.\s*/, "").strip
        elsif current && continuation_line?(stripped)
          current = "#{current} #{stripped}"
        else
          # Non-continuation line (section heading, etc.) — flush
          if current
            paragraphs << current unless english_text?(current)
            current = nil
          end
        end
      end

      paragraphs << current if current && !english_text?(current)

      paragraphs
        .map { |p| clean_text(p) }
        .reject { |p| p.length < 20 }
    end

    def numbered_paragraph_start?(line)
      line.match?(/\A\d{1,3}[*.]*\.\s/) && !line.match?(/\A\d+\.\s+\d+\s/)
    end

    def page_header?(line)
      stripped = line.strip
      # Even page: "16  SECTION I.— FROM THE CREATION TO"
      return true if stripped.match?(/\A\d+\s+SECTION\s+[IVX]/i)
      # Odd page: "THE DISPERSAL OF THE NATIONS.  17"
      return true if stripped.match?(/[A-Z]{3,}\.?\s+\d+\s*\z/) && stripped.length > 20
      # Page number only
      return true if stripped.match?(/\A\d+\z/) && stripped.to_i.between?(1, 999)
      false
    end

    def apparatus_line?(line)
      stripped = line.strip
      # Variant readings: "1  dorindi  2  fuil  tosach"
      return true if stripped.match?(/\A\d+[*.]*\s+[a-z]/) && stripped.match?(/\d+\s+[a-z].*\d+\s+[a-z]/)
      # Apparatus with manuscript sigla: "All variants from F unless"
      return true if stripped.match?(/\AAll\s+variants\s+from/i)
      # Footnote references: "(a)  For the text of *Q"
      return true if stripped.match?(/\A\([a-z]\)\s+For\s+the/i)
      # Volume/line reference: "L.G.— VOL.  I."
      return true if stripped.match?(/\AL\.G\./i)
      false
    end

    def continuation_line?(line)
      stripped = line.strip
      return false if stripped.empty?
      return false if stripped.match?(/\A[A-Z][A-Z\s]{10,}\z/) # All-caps heading
      return false if stripped.match?(/\A(First|Second|Third)\s+(Redaction|Reduction)/i)
      return false if stripped.match?(/\APoem\s+no\./i)
      return false if stripped.match?(/\ANotes?\s+on/i)
      return false if stripped.match?(/\AVERSE\s+TEXTS/i)
      true
    end

    def english_text?(text)
      words = text.downcase.scan(/[a-z]+/)
      return true if words.size < 3
      english_count = words.count { |w| ENGLISH_STOP_WORDS.include?(w) }
      english_count.to_f / words.size > 0.15
    end

    def clean_text(text)
      text
        .gsub(/\s+/, " ")
        .gsub(/[''ʼ]/, "'")
        .gsub(/["""]/, '"')
        .gsub(/\|\|/, "") # Remove glossarial markers
        .gsub(/\s*\$\s*/, " ") # Remove section markers
        .gsub(/\s*[\\%X]\s*/, " ") # Remove tironian/sigla artifacts
        .gsub(/\d+(?=[A-Z])/, "") # Remove superscript numbers before words
        .gsub(/\s+/, " ")
        .strip
    end

    def ensure_tradition_and_corpus
      tradition = Tradition.find_or_create_by!(slug: "celtic") do |t|
        t.name = "Celtic"
        t.description = "Welsh, Irish, and Scottish mythological and literary traditions " \
                        "including the Mabinogion, Ulster Cycle, and Fenian Cycle."
      end

      @corpus = Corpus.find_or_create_by!(slug: "celtic-literature") do |c|
        c.name = "Celtic Literature"
        c.tradition = tradition
        c.description = "Welsh, Irish, and Scottish mythological and literary texts."
      end
    end

    def ensure_translation
      Translation.find_or_create_by!(abbreviation: "LGE", corpus: @corpus) do |t|
        t.name = "Macalister Critical Edition (1938–1956)"
        t.language = "Old Irish"
        t.edition_type = "original"
      end
    end
  end
end
