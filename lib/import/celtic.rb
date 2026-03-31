module Import
  class Celtic
    # Imports Celtic literary texts from Project Gutenberg plain text.
    #
    # Supports section-based prose narratives:
    #   - The Mabinogion (Lady Charlotte Guest, 1849) — Welsh mythology
    #   - Táin Bó Cúailnge (Joseph Dunn, 1914) — Irish epic
    #
    # Mapping:
    #   Tradition "Celtic" → Corpus "Celtic Literature" → Scripture
    #   → Division (one per tale/chapter) → Passage (one per paragraph)
    #   → PassageTranslation (English)

    GUTENBERG_START = /\*{3}\s*START OF/i
    GUTENBERG_END = /\*{3}\s*END OF/i

    # Skip front/back matter sections
    SKIP_HEADINGS = %w[
      INTRODUCTION PREFACE CONTENTS NOTES BIBLIOGRAPHY APPENDIX
      GLOSSARY INDEX PRONUNCIATION COLOPHON
    ].freeze

    def initialize(file:, scripture_name:, scripture_slug:, scripture_description:,
                   translation_abbreviation:, translation_name:,
                   corpus_name: "Celtic Literature", corpus_slug: "celtic-literature",
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

      text = strip_gutenberg_wrapper(raw)
      sections = parse_sections(text)
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

          PassageTranslation.find_or_create_by!(passage: passage, translation: translation) do |pt|
            pt.text = para_text
          end

          done += 1
          @progress&.call(done, total_paragraphs) if done % 50 == 0
        end
      end

      @progress&.call(total_paragraphs, total_paragraphs)
      puts "  #{@scripture_name}: #{done} passages across #{sections.size} sections"
    end

    private

    def strip_gutenberg_wrapper(raw)
      lines = raw.lines
      start_idx = lines.index { |l| l.match?(GUTENBERG_START) }
      end_idx = lines.rindex { |l| l.match?(GUTENBERG_END) }

      if start_idx && end_idx
        lines[(start_idx + 1)...end_idx].join
      elsif start_idx
        lines[(start_idx + 1)..].join
      else
        raw
      end
    end

    def parse_sections(text)
      lines = text.lines.map(&:rstrip)
      sections = []
      current_section = nil
      current_paragraph = nil

      lines.each do |line|
        stripped = line.strip

        if section_heading?(stripped)
          flush_paragraph(current_section, current_paragraph)
          current_paragraph = nil
          sections << current_section if current_section && current_section[:paragraphs].any?
          current_section = { title: titleize(stripped), paragraphs: [] }
        elsif current_section
          if stripped.empty?
            flush_paragraph(current_section, current_paragraph)
            current_paragraph = nil
          elsif current_paragraph
            current_paragraph = "#{current_paragraph} #{stripped}"
          else
            current_paragraph = stripped
          end
        end
      end

      flush_paragraph(current_section, current_paragraph)
      sections << current_section if current_section && current_section[:paragraphs].any?

      # Clean up and filter
      sections.each do |s|
        s[:paragraphs] = s[:paragraphs]
          .map { |p| clean_text(p) }
          .reject { |p| p.length < 30 }
      end

      sections
        .reject { |s| s[:paragraphs].empty? }
        .reject { |s| skip_heading?(s[:title]) }
    end

    def flush_paragraph(section, paragraph)
      section[:paragraphs] << paragraph if section && paragraph
    end

    def section_heading?(line)
      return false if line.empty?
      return false if line.length > 100
      return false if line.length < 4
      return false if line.match?(/\A\d+\z/)           # Page numbers
      return false if line.match?(/\A[ivxlcdm]+\z/i)   # Roman page numbers
      return false if line.end_with?(".")               # Sentences
      return false if line.end_with?(",")

      # All-caps line with at least 2 words (primary heading style in Gutenberg)
      return true if line.match?(/\A[A-Z][A-Z\s'',.:\-—]+\z/) && line.split.size >= 2

      false
    end

    def skip_heading?(title)
      normalized = title.upcase.gsub(/[^A-Z\s]/, "").strip
      SKIP_HEADINGS.any? { |skip| normalized.start_with?(skip) }
    end

    def titleize(text)
      small_words = %w[of the and in to a an on for at by with]
      text.strip.split.map.with_index { |w, i|
        if i > 0 && small_words.include?(w.downcase)
          w.downcase
        else
          w.capitalize
        end
      }.join(" ")
    end

    def clean_text(text)
      text
        .gsub(/\s+/, " ")
        .gsub(/[''ʼ]/, "'")
        .gsub(/["""]/, '"')
        .strip
    end

    def ensure_tradition_and_corpus
      tradition = Tradition.find_or_create_by!(slug: "celtic") do |t|
        t.name = "Celtic"
        t.description = "Welsh, Irish, and Scottish mythological and literary traditions " \
                        "including the Mabinogion, Ulster Cycle, and Fenian Cycle."
      end

      @corpus = Corpus.find_or_create_by!(slug: @corpus_slug) do |c|
        c.name = @corpus_name
        c.tradition = tradition
        c.description = @corpus_description || "Welsh, Irish, and Scottish mythological and literary texts."
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
