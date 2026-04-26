module Import
  class LeborGabalaEnglish
    # Imports the English translation pages from Macalister's critical edition
    # of Lebor Gabála Érenn (Irish Texts Society, 5 vols., 1938–1956).
    #
    # Copyright status:
    #   - In the EU and Ireland the work entered the public domain on
    #     1 January 2021 (R. A. S. Macalister died 1950; life + 70 years).
    #   - In the United States the URAA-restored copyright runs through
    #     2034+, so the English text should not be served to US users
    #     until the underlying rights expire.
    #
    # Structurally the source mirrors `Import::LeborGabala`: numbered
    # paragraphs alternate with the facing-page Old Irish text. The Old
    # Irish importer's `english_text?` heuristic is inverted here to keep
    # only paragraphs whose function-word density looks English.
    #
    # Mapping:
    #   Tradition "Celtic" → Corpus "Celtic Literature"
    #   → Scripture "Lebor Gabála Érenn"
    #   → Division (one per volume) → Passage (one per numbered paragraph)
    #   → TranslationSegment (English)

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
        s.position = (Scripture.where(corpus: @corpus).maximum(:position) || 0) + 1
        s.description = "The Book of the Taking of Ireland."
      end

      translation = ensure_translation

      total_paragraphs = 0
      done = 0

      volumes = @files.each_with_index.map do |file, idx|
        volume_number = idx + 1
        next unless file.exist?

        raw = File.read(file, encoding: "UTF-8")
        raw.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")
        paragraphs = extract_english_paragraphs(raw)
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

          TranslationSegment.find_or_create_for_range(
            translation: translation, start_passage: passage, end_passage: passage, text: para_text
          )

          done += 1
          @progress&.call(done, total_paragraphs) if done % 50 == 0
        end
      end

      @progress&.call(total_paragraphs, total_paragraphs)
      puts "  Lebor Gabála Érenn (English): #{done} paragraphs across #{volumes.size} volumes"
    end

    private

    def extract_english_paragraphs(raw)
      lines = raw.lines.map(&:rstrip)

      text_start = lines.index { |l| l.strip.match?(/\A\d{1,3}[*.]*\.\s/) && !page_header?(l) }
      return [] unless text_start

      lines = lines[text_start..]

      paragraphs = []
      current = nil

      lines.each do |line|
        stripped = line.strip
        next if stripped.empty?
        next if page_header?(stripped)
        next if apparatus_line?(stripped)

        if numbered_paragraph_start?(stripped)
          paragraphs << current if current && english_text?(current)
          current = stripped.sub(/\A\d{1,3}[*.]*\.\s*/, "").strip
        elsif current && continuation_line?(stripped)
          current = "#{current} #{stripped}"
        else
          paragraphs << current if current && english_text?(current)
          current = nil
        end
      end

      paragraphs << current if current && english_text?(current)

      paragraphs
        .map { |p| clean_text(p) }
        .reject { |p| p.length < 20 }
    end

    def numbered_paragraph_start?(line)
      line.match?(/\A\d{1,3}[*.]*\.\s/) && !line.match?(/\A\d+\.\s+\d+\s/)
    end

    def page_header?(line)
      stripped = line.strip
      return true if stripped.match?(/\A\d+\s+SECTION\s+[IVX]/i)
      return true if stripped.match?(/[A-Z]{3,}\.?\s+\d+\s*\z/) && stripped.length > 20
      return true if stripped.match?(/\A\d+\z/) && stripped.to_i.between?(1, 999)
      false
    end

    def apparatus_line?(line)
      stripped = line.strip
      return true if stripped.match?(/\A\d+[*.]*\s+[a-z]/) && stripped.match?(/\d+\s+[a-z].*\d+\s+[a-z]/)
      return true if stripped.match?(/\AAll\s+variants\s+from/i)
      return true if stripped.match?(/\A\([a-z]\)\s+For\s+the/i)
      return true if stripped.match?(/\AL\.G\./i)
      false
    end

    def continuation_line?(line)
      stripped = line.strip
      return false if stripped.empty?
      return false if stripped.match?(/\A[A-Z][A-Z\s]{10,}\z/)
      return false if stripped.match?(/\A(First|Second|Third)\s+(Redaction|Reduction)/i)
      return false if stripped.match?(/\APoem\s+no\./i)
      return false if stripped.match?(/\ANotes?\s+on/i)
      return false if stripped.match?(/\AVERSE\s+TEXTS/i)
      true
    end

    def english_text?(text)
      words = text.downcase.scan(/[a-z]+/)
      return false if words.size < 3
      english_count = words.count { |w| ENGLISH_STOP_WORDS.include?(w) }
      english_count.to_f / words.size > 0.15
    end

    def clean_text(text)
      text
        .gsub(/\s+/, " ")
        .gsub(/[''ʼ]/, "'")
        .gsub(/["""]/, '"')
        .gsub(/\|\|/, "")
        .gsub(/\s*\$\s*/, " ")
        .gsub(/\s*[\\%X]\s*/, " ")
        .gsub(/\d+(?=[A-Z])/, "")
        .gsub(/\s+/, " ")
        .strip
    end

    def ensure_tradition_and_corpus
      tradition = Tradition.find_or_create_by!(slug: "celtic") do |t|
        t.name = "Celtic"
      end

      @corpus = Corpus.find_or_create_by!(slug: "celtic-literature") do |c|
        c.name = "Celtic Literature"
        c.tradition = tradition
      end
    end

    def ensure_translation
      Translation.find_or_create_by!(abbreviation: "LGE-EN", corpus: @corpus) do |t|
        t.name = "Macalister Critical Edition — English (1938–1956)"
        t.language = "English"
        t.edition_type = "critical"
        t.description = "Public domain in the EU/Ireland from 2021 (Macalister d. 1950, life+70). " \
                        "Restored under URAA in the United States until 2034+; restrict access " \
                        "where US copyright applies."
      end
    end
  end
end
