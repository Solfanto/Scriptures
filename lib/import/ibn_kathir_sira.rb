module Import
  class IbnKathirSira
    # Imports Ibn Kathir's Al-Sira al-Nabawiyya (14th c. Arabic prophetic biography) from
    # an Arabic plain-text source file (Internet Archive DjVu or similar UTF-8 text).
    #
    # Trevor Le Gassick's English translation (1998–2000) remains under copyright
    # and is not imported here; only the public-domain Arabic original is loaded.
    #
    # Mapping:
    #   Tradition "Islamic" → Corpus "Sira" → Scripture "Al-Sira al-Nabawiyya (Ibn Kathir)"
    #   → Division (one per detected section heading) → Passage (one per paragraph)
    #   → TranslationSegment (Arabic)

    # Headings in classical Arabic Sira texts. Patterns are matched against
    # whitespace-collapsed line starts; any of these prefixes opens a new section.
    SECTION_PREFIXES = [
      "الفصل",       # "the chapter"
      "الباب",       # "the book/gate"
      "غزوة",        # "expedition / campaign"
      "سرية",        # "raid"
      "ذكر",         # "the mention of"
      "بعث",         # "the dispatch of"
      "وفد",         # "delegation"
      "خبر",         # "the report of"
      "هجرة"         # "the emigration"
    ].freeze

    SECTION_REGEX = /\A\s*(#{SECTION_PREFIXES.join("|")})\b/

    def initialize(file:, progress: nil)
      @file = Pathname.new(file)
      @progress = progress
    end

    def run
      unless @file.exist?
        puts "  Ibn Kathir Sira: source file not found at #{@file}; skipping"
        return
      end

      raw = File.read(@file, encoding: "UTF-8")
      raw.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")

      ensure_tradition_and_corpus

      scripture = Scripture.find_or_create_by!(corpus: @sira_corpus, slug: "al-sira-al-nabawiyya-ibn-kathir") do |s|
        s.name = "Al-Sira al-Nabawiyya (Ibn Kathir)"
        s.position = (Scripture.where(corpus: @sira_corpus).maximum(:position) || 0) + 1
        s.description = "Ibn Kathir's biography of the Prophet Muhammad, extracted from his " \
                        "universal history Al-Bidaya wa-l-Nihaya. Composed in 14th-century Damascus, " \
                        "it draws on Ibn Ishaq, Ibn Hisham, al-Waqidi, and al-Tabari. " \
                        "The Arabic original is public domain; Trevor Le Gassick's English " \
                        "translation (1998–2000) remains under copyright and is not included."
      end

      arabic_translation = ensure_translation("IKA", "Al-Sira al-Nabawiyya (Arabic)", "Arabic", edition_type: "original")

      sections = parse_sections(raw)
      total_paragraphs = sections.sum { |s| s[:paragraphs].size }
      done = 0

      @progress&.call(0, total_paragraphs)

      sections.each_with_index do |section, idx|
        division_number = idx + 1
        division = Division.find_or_create_by!(scripture: scripture, number: division_number) do |d|
          d.name = section[:title]
          d.position = division_number
        end

        section[:paragraphs].each_with_index do |para_text, pidx|
          passage_number = pidx + 1
          passage = Passage.find_or_create_by!(division: division, number: passage_number) do |p|
            p.position = passage_number
          end

          TranslationSegment.find_or_create_for_range(
            translation: arabic_translation, start_passage: passage, end_passage: passage, text: para_text
          )

          done += 1
          @progress&.call(done, total_paragraphs) if done % 50 == 0
        end
      end

      @progress&.call(total_paragraphs, total_paragraphs)
      puts "  Al-Sira al-Nabawiyya (Ibn Kathir): #{done} paragraphs across #{sections.size} sections"
    end

    private

    def parse_sections(raw)
      lines = raw.lines.map(&:rstrip)

      sections = []
      current = nil

      lines.each do |line|
        stripped = line.strip
        next if junk_line?(stripped)

        if !stripped.empty? && section_heading?(stripped)
          finalize(current, sections)
          current = { title: clean_heading(stripped), buffer: [] }
        elsif current
          # Preserve blank lines inside a section so paragraphs_from_lines can split on them.
          current[:buffer] << stripped
        end
      end

      finalize(current, sections)

      # If we never found a heading, fall back to a single division of paragraphs.
      if sections.empty?
        paragraphs = paragraphs_from_lines(lines.reject { |l| junk_line?(l.strip) })
        sections << { title: "Al-Sira al-Nabawiyya", paragraphs: paragraphs } if paragraphs.any?
      end

      sections
    end

    def finalize(section, sections)
      return unless section

      paragraphs = paragraphs_from_lines(section[:buffer])
      return if paragraphs.empty?

      sections << { title: section[:title], paragraphs: paragraphs }
    end

    # Group consecutive non-blank lines into paragraphs. A blank line separates paragraphs.
    def paragraphs_from_lines(lines)
      paragraphs = []
      buffer = []

      lines.each do |line|
        if line.to_s.strip.empty?
          paragraphs << buffer.join(" ").strip if buffer.any?
          buffer = []
        else
          buffer << line.strip
        end
      end

      paragraphs << buffer.join(" ").strip if buffer.any?
      paragraphs.reject { |p| p.length < 20 }
    end

    def section_heading?(line)
      return false if line.length > 120
      line.match?(SECTION_REGEX)
    end

    def clean_heading(line)
      line.gsub(/\s+/, " ").strip
    end

    # Skip page numbers, isolated digits, and other DjVu artefacts.
    def junk_line?(line)
      return true if line.match?(/\A\d+\z/)
      return true if line.match?(/\A[ivxlcdm]+\z/i) && line.length <= 6
      false
    end

    def ensure_tradition_and_corpus
      islamic = Tradition.find_or_create_by!(slug: "islamic") do |t|
        t.name = "Islamic"
      end

      @sira_corpus = Corpus.find_or_create_by!(slug: "sira") do |c|
        c.name = "Sira"
        c.tradition = islamic
        c.description = "Prophetic biography (Sirat al-Nabawiyyah). The earliest biographical " \
                        "accounts of the Prophet Muhammad, compiled from oral traditions and " \
                        "historical reports by early Muslim historians."
      end
    end

    def ensure_translation(abbreviation, name, language, edition_type: nil)
      Translation.find_or_create_by!(abbreviation: abbreviation, corpus: @sira_corpus) do |t|
        t.name = name
        t.language = language
        t.edition_type = edition_type if edition_type
      end
    end
  end
end
