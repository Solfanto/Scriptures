module Import
  class Mesopotamian
    # Imports Mesopotamian literary texts from Internet Archive DjVu plain text.
    #
    # Supports tablet-based ancient texts with numbered verse lines:
    #   - Epic of Gilgamesh (R. Campbell Thompson, 1928) — public domain
    #   - Enuma Elish / Babylonian Legends of Creation (E.A. Wallis Budge, 1921) — public domain
    #
    # Mapping:
    #   Tradition "Mesopotamian" → Corpus → Scripture
    #   → Division (one per tablet) → Passage (one per verse line)
    #   → TranslationSegment (English)

    TABLET_WORDS = %w[first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth].freeze
    TABLET_PATTERN = /\b(#{TABLET_WORDS.join("|")})\s+tablet\b/i

    def initialize(file:, scripture_name:, scripture_slug:, scripture_description:,
                   translation_abbreviation:, translation_name:,
                   corpus_name: "Mesopotamian Literature", corpus_slug: "mesopotamian-literature",
                   corpus_description: nil, progress: nil)
      @file = Pathname.new(file)
      @scripture_name = scripture_name
      @scripture_slug = scripture_slug
      @scripture_description = scripture_description
      @translation_abbreviation = translation_abbreviation
      @translation_name = translation_name
      @corpus_name = corpus_name
      @corpus_slug = corpus_slug
      @corpus_description = corpus_description
      @progress = progress
    end

    def run
      raw = File.read(@file, encoding: "UTF-8")
      raw.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")

      ensure_tradition_and_corpus

      scripture = Scripture.find_or_create_by!(corpus: @corpus, slug: @scripture_slug) do |s|
        s.name = @scripture_name
        s.position = Scripture.where(corpus: @corpus).count + 1
        s.description = @scripture_description
      end

      translation = ensure_translation

      tablets = parse_tablets(raw)
      total_lines = tablets.sum { |t| t[:lines].size }
      done = 0

      @progress&.call(0, total_lines)

      tablets.each do |tablet|
        division = Division.find_or_create_by!(scripture: scripture, number: tablet[:number]) do |d|
          d.name = "Tablet #{roman(tablet[:number])}"
          d.position = tablet[:number]
        end

        tablet[:lines].each_with_index do |line_text, idx|
          passage_number = idx + 1
          passage = Passage.find_or_create_by!(division: division, number: passage_number) do |p|
            p.position = passage_number
          end

          TranslationSegment.find_or_create_for_range(
            translation: translation, start_passage: passage, end_passage: passage, text: line_text
          )

          done += 1
          @progress&.call(done, total_lines) if done % 50 == 0
        end
      end

      @progress&.call(total_lines, total_lines)
      puts "  #{@scripture_name}: #{done} lines across #{tablets.size} tablets"
    end

    private

    def parse_tablets(raw)
      lines = raw.lines.map(&:rstrip)

      # Find all tablet heading positions
      tablet_starts = []
      lines.each_with_index do |line, idx|
        number = detect_tablet_heading(line)
        # Only accept if this is a new tablet (avoid duplicates from transliteration sections)
        if number && tablet_starts.none? { |ts| ts[:number] == number }
          tablet_starts << { index: idx, number: number }
        end
      end

      return [] if tablet_starts.empty?

      # Extract content between tablets
      tablets = []
      tablet_starts.each_with_index do |start, i|
        end_idx = i + 1 < tablet_starts.size ? tablet_starts[i + 1][:index] : lines.size
        content_lines = lines[(start[:index] + 1)...end_idx]
        verse_lines = extract_verses(content_lines)
        tablets << { number: start[:number], lines: verse_lines } if verse_lines.any?
      end

      tablets
    end

    def detect_tablet_heading(line)
      stripped = line.strip
      return nil if stripped.length > 120 || stripped.length < 8

      match = stripped.match(TABLET_PATTERN)
      return nil unless match

      word = match[1].downcase
      TABLET_WORDS.index(word)&.+(1)
    end

    def extract_verses(content_lines)
      verses = []
      current_verse = nil
      in_notes = false

      content_lines.each do |line|
        stripped = line.strip
        next if stripped.empty?

        # Detect and skip notes sections
        if stripped.match?(/\ANOTES?\s*[.—:\-]/i)
          in_notes = true
          verses << current_verse if current_verse
          current_verse = nil
        end

        # Reset notes flag at next column or section marker
        if in_notes && stripped.match?(/\AColumn\s+[IVX]+/i)
          in_notes = false
          next
        end
        next if in_notes

        # Skip metadata lines
        next if stripped.match?(/\AColumn\s+[IVX]+/i)       # Column markers
        next if stripped.match?(/\A\(.*\)\z/)                # Entirely parenthetical
        next if stripped.match?(/\A\d+\z/)                   # Bare page numbers
        next if stripped.match?(/\A[ivxlcdm]+\z/i)           # Roman numeral page numbers
        next if stripped.match?(/\AOF[.\s]/i) && stripped.length < 80 # Subtitle lines
        next if stripped.match?(/\ATRANSLAT/i)               # "TRANSLATION" headers
        next if stripped.match?(/\ATRANSLITER/i)             # "TRANSLITERATION" headers
        next if stripped.match?(/\A[A-Z\s]{20,}\z/)          # All-caps headings (> 20 chars)

        # Detect numbered verse line: starts with 1-3 digits
        if stripped.match?(/\A\d{1,3}[.\s,]/)
          verses << current_verse if current_verse
          current_verse = stripped.sub(/\A\d{1,3}[.\s,]\s*/, "").strip
        elsif stripped.match?(/\A\d{1,3}[A-Z]/)
          # Thompson style: "1He who..." — number directly followed by uppercase letter
          verses << current_verse if current_verse
          current_verse = stripped.sub(/\A\d{1,3}/, "").strip
        elsif current_verse
          # Continuation of previous verse
          current_verse = "#{current_verse} #{stripped}"
        end
      end

      verses << current_verse if current_verse

      # Clean up and filter
      verses
        .map { |v| clean_verse(v) }
        .reject { |v| v.length < 10 }
    end

    def clean_verse(text)
      text
        .gsub(/\s+/, " ")
        .gsub(/[''ʼ]/, "'")
        .gsub(/["""]/, '"')
        .gsub(/\.{3,}/, "...")        # Normalize ellipses
        .gsub(/\s*\.\.\.\s*/, "...")   # Tighten ellipsis spacing
        .strip
    end

    ROMAN_NUMERALS = %w[I II III IV V VI VII VIII IX X XI XII].freeze

    def roman(n)
      ROMAN_NUMERALS[n - 1] || n.to_s
    end

    def ensure_tradition_and_corpus
      tradition = Tradition.find_or_create_by!(slug: "mesopotamian") do |t|
        t.name = "Mesopotamian"
        t.description = "Sumerian, Babylonian, and Assyrian texts including the Epic of Gilgamesh and Enuma Elish."
      end

      @corpus = Corpus.find_or_create_by!(slug: @corpus_slug) do |c|
        c.name = @corpus_name
        c.tradition = tradition
        c.description = @corpus_description || "Sumerian, Babylonian, and Assyrian literary and religious texts."
      end
    end

    def ensure_translation
      Translation.find_or_create_by!(abbreviation: @translation_abbreviation, corpus: @corpus) do |t|
        t.name = @translation_name
        t.language = "English"
        t.edition_type = "critical"
      end
    end
  end
end
