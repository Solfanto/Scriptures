module Import
  class Sira
    # Imports the Sira (biography of the Prophet Muhammad) from DjVu plain text.
    #
    # Source: Abdus-Salam M. Harun's abridgement of Ibn Hisham's recension
    # of Ibn Ishaq's Sirat Rasul Allah, available on Internet Archive.
    # Copyright status unclear — original Arabic text (9th century) is public domain;
    # this English translation's copyright status is undetermined.
    #
    # Mapping:
    #   Corpus "Sira" → Scripture "Sirat Rasul Allah"
    #   → Division (top-level: Part I–VII) → Division (nested: sections)
    #   → Passage (one per paragraph) → TranslationSegment (English)

    PARTS = [
      { number: 1, title: "The Prophet and the Arabian Peninsula Before the Mission" },
      { number: 2, title: "The Mission and Da'wah to Islam Until the Emigration" },
      { number: 3, title: "The General Emigration" },
      { number: 4, title: "The Pillars of the Muslim Community" },
      { number: 5, title: "The Blessed Struggle" },
      { number: 6, title: "A New Stage" },
      { number: 7, title: "The End of the Blessed Journey in the Worldly Life" }
    ].freeze

    def self.part_patterns
      @part_patterns ||= PARTS.map { |p| [ normalize(p[:title]), p[:number] ] }.freeze
    end

    def initialize(file:, progress: nil)
      @file = Pathname.new(file)
      @progress = progress
    end

    def run
      raw = File.read(@file, encoding: "UTF-8")
      raw.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")

      ensure_tradition_and_corpus

      scripture = Scripture.find_or_create_by!(corpus: @sira_corpus, slug: "sirat-rasul-allah") do |s|
        s.name = "Sirat Rasul Allah"
        s.position = 1
        s.description = "The earliest surviving biography of the Prophet Muhammad, compiled by " \
                        "Ibn Ishaq (d. 767) and edited by Ibn Hisham (d. 834). " \
                        "Abridged English translation by Abdus-Salam M. Harun."
      end

      english_translation = ensure_translation("SEN", "Sira English", "English")

      parts_data = parse_text(raw)
      total = 0

      total_sections = parts_data.sum { |p| p[:sections].size }
      sections_done = 0
      @progress&.call(0, total_sections)

      parts_data.each do |part|
        part_info = PARTS.find { |p| p[:number] == part[:number] } || { title: "Part #{part[:number]}" }

        part_division = Division.find_or_create_by!(scripture: scripture, number: part[:number]) do |d|
          d.name = part_info[:title]
          d.position = part[:number]
        end

        part[:sections].each_with_index do |section, idx|
          section_number = idx + 1
          section_division = Division.find_or_create_by!(
            scripture: scripture,
            number: part[:number] * 100 + section_number
          ) do |d|
            d.name = section[:title]
            d.position = section_number
            d.parent = part_division
          end

          section[:paragraphs].each_with_index do |text, pidx|
            passage_number = pidx + 1
            passage = Passage.find_or_create_by!(division: section_division, number: passage_number) do |p|
              p.position = passage_number
            end

            TranslationSegment.find_or_create_for_range(
              translation: english_translation, start_passage: passage, end_passage: passage, text: text
            )

            total += 1
          end

          sections_done += 1
          @progress&.call(sections_done, total_sections)
        end
      end

      puts "  Sirat Rasul Allah: #{total} passages imported (#{parts_data.sum { |p| p[:sections].size }} sections across #{parts_data.size} parts)"
    end

    private

    def parse_text(raw)
      lines = raw.lines.map(&:rstrip)

      # Skip front matter: find the first part heading
      start_idx = find_first_part_heading(lines)
      return [] unless start_idx

      lines = lines[start_idx..]

      # Split into parts
      parts = []
      current_part = nil

      lines.each do |line|
        part_number = detect_part_heading(line)
        if part_number
          parts << current_part if current_part
          current_part = { number: part_number, lines: [] }
        elsif current_part
          current_part[:lines] << line
        end
      end
      parts << current_part if current_part

      # Parse sections within each part
      parts.map do |part|
        sections = parse_sections(part[:lines])
        { number: part[:number], sections: sections }
      end
    end

    def find_first_part_heading(lines)
      lines.each_with_index do |line, idx|
        return idx if detect_part_heading(line)
      end
      nil
    end

    def detect_part_heading(line)
      normalized = self.class.normalize(line)
      return nil if normalized.length < 10 || normalized.length > 120

      self.class.part_patterns.each do |pattern, number|
        # Fuzzy match: check if most words from the pattern appear in the line
        pattern_words = pattern.split
        line_words = normalized.split
        matches = pattern_words.count { |w| line_words.any? { |lw| lw.include?(w) || w.include?(lw) } }
        return number if matches >= (pattern_words.size * 0.6).ceil
      end

      nil
    end

    def parse_sections(lines)
      sections = []
      current_section = nil

      lines.each do |line|
        if section_heading?(line)
          sections << current_section if current_section && current_section[:paragraphs].any?
          current_section = { title: clean_heading(line), paragraphs: [] }
        elsif current_section
          if line.strip.empty?
            # Blank line — paragraph separator (handled below)
            next
          else
            # Accumulate text into paragraphs
            if current_section[:paragraphs].empty? || paragraph_break?(current_section[:last_was_blank])
              current_section[:paragraphs] << line.strip
            else
              current_section[:paragraphs][-1] = "#{current_section[:paragraphs][-1]} #{line.strip}"
            end
          end
        end

        current_section[:last_was_blank] = line.strip.empty? if current_section
      end

      sections << current_section if current_section && current_section[:paragraphs].any?

      # Clean up: remove the tracking key and filter out short noise paragraphs
      sections.each do |s|
        s.delete(:last_was_blank)
        s[:paragraphs].reject! { |p| p.length < 20 }
      end

      sections.reject { |s| s[:paragraphs].empty? }
    end

    def section_heading?(line)
      stripped = line.strip
      return false if stripped.empty?
      return false if stripped.length > 100
      return false if stripped.length < 5

      # Skip lines that look like page numbers or artifacts
      return false if stripped.match?(/\A\d+\z/)
      return false if stripped.match?(/\A[ivxlcdm]+\z/i)

      # Section headings are typically short, title-cased, and don't end with period
      return false if stripped.end_with?(".")
      return false if stripped.end_with?(",")
      return false if stripped.match?(/[a-z]{3,}\s+[a-z]{3,}\s+[a-z]{3,}\s+[a-z]{3,}\s+[a-z]{3,}/)

      # Must start with a capital letter
      return false unless stripped.match?(/\A[A-Z]/)

      # Typically 2-10 words
      word_count = stripped.split.size
      return false if word_count > 12
      return false if word_count < 2

      # Most words should be capitalized (Title Case)
      words = stripped.split
      capitalized = words.count { |w| w.match?(/\A[A-Z]/) || %w[the of and in to a an ibn].include?(w.downcase) }
      capitalized >= (words.size * 0.6).ceil
    end

    def paragraph_break?(last_was_blank)
      last_was_blank == true
    end

    def clean_heading(line)
      line.strip
        .gsub(/\s+/, " ")
        .sub(/\A\d+[\.\)]\s*/, "")  # Remove leading numbers
    end

    def self.normalize(text)
      text.to_s
        .downcase
        .gsub(/[^a-z0-9\s]/, "")
        .gsub(/\s+/, " ")
        .strip
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

    def ensure_translation(abbreviation, name, language)
      Translation.find_or_create_by!(abbreviation: abbreviation, corpus: @sira_corpus) do |t|
        t.name = name
        t.language = language
      end
    end
  end
end
