module Import
  class Fiqh
    # Imports Islamic legal texts (fiqh and usul al-fiqh) from OpenITI's
    # mARkdown corpus, an open-access collection of 1,800+ premodern Arabic
    # works prepared for the Knowledge Integration through Text Analysis
    # project at the Aga Khan University.
    #
    # OpenITI mARkdown format conventions used here:
    #   #META#       — front-matter metadata (skipped)
    #   #            — primary structural heading (book / kitab)
    #   ## … #       — secondary heading (chapter / bab)
    #   ### … #      — tertiary heading (section / fasl)
    #   #~~          — paragraph (milestone) marker; opens a new paragraph
    #   ~~           — soft line break inside a paragraph
    #   PageVxxPxxx  — pagination markers (stripped)
    #
    # The OpenITI corpus is licensed for scholarly use; the underlying
    # premodern Arabic works are themselves public domain.
    #
    # Mapping:
    #   Tradition "Islamic" → Corpus "Fiqh" → Scripture (one per work)
    #   → Division (one per top-level book / kitab)
    #   → Division (nested: chapter / bab)
    #   → Passage (one per paragraph) → TranslationSegment (Arabic)

    METADATA_REGEX = /\A#META#/
    # Heading lines: one or more `#` followed by a space and the title (e.g. `# kitab #`).
    # Paragraphs (`#~~ …`) and metadata are excluded because they have no space after `#`.
    HEADING_REGEX = /\A(#+) (.+?)\s*#?\s*\z/
    PARAGRAPH_REGEX = /\A#~~(.*)/
    SOFT_BREAK = "~~".freeze
    PAGE_MARKER = /Page[Vv]\d+[Pp]\d+/

    def initialize(file:, scripture_name:, scripture_slug:, scripture_description:,
                   translation_abbreviation:, translation_name:,
                   progress: nil)
      @file = Pathname.new(file)
      @scripture_name = scripture_name
      @scripture_slug = scripture_slug
      @scripture_description = scripture_description
      @translation_abbreviation = translation_abbreviation
      @translation_name = translation_name
      @progress = progress
    end

    def run
      unless @file.exist?
        puts "  Fiqh (#{@scripture_name}): source file not found at #{@file}; skipping"
        return
      end

      raw = File.read(@file, encoding: "UTF-8")
      raw.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")

      ensure_tradition_and_corpus

      scripture = Scripture.find_or_create_by!(corpus: @fiqh_corpus, slug: @scripture_slug) do |s|
        s.name = @scripture_name
        s.position = (Scripture.where(corpus: @fiqh_corpus).maximum(:position) || 0) + 1
        s.description = @scripture_description
      end

      translation = ensure_translation

      tree = parse_tree(raw)
      total_paragraphs = count_paragraphs(tree)
      done = 0

      @progress&.call(0, total_paragraphs)

      tree.each_with_index do |book, book_idx|
        book_division = Division.find_or_create_by!(scripture: scripture, number: book_idx + 1) do |d|
          d.name = book[:title]
          d.position = book_idx + 1
        end

        # Import paragraphs that sit at the book level (before any chapter)
        book[:paragraphs].each_with_index do |text, pidx|
          create_passage(book_division, pidx + 1, translation, text)
          done += 1
        end

        book[:children].each_with_index do |chapter, chapter_idx|
          chapter_number = (book_idx + 1) * 1000 + (chapter_idx + 1)
          chapter_division = Division.find_or_create_by!(scripture: scripture, number: chapter_number) do |d|
            d.name = chapter[:title]
            d.position = chapter_idx + 1
            d.parent = book_division
          end

          chapter_paragraphs = chapter[:paragraphs] + chapter[:children].flat_map { |c| c[:paragraphs] }
          chapter_paragraphs.each_with_index do |text, pidx|
            create_passage(chapter_division, pidx + 1, translation, text)
            done += 1
            @progress&.call(done, total_paragraphs) if done % 100 == 0
          end
        end
      end

      @progress&.call(total_paragraphs, total_paragraphs)
      puts "  #{@scripture_name}: #{done} paragraphs across #{tree.size} books"
    end

    private

    # Parse the mARkdown into a nested tree:
    #   [{ title:, paragraphs: [...], children: [{ title:, paragraphs:, children: [...] }] }]
    def parse_tree(raw)
      tree = []
      stack = [] # stack of { level:, node: }

      current_paragraph = nil

      raw.each_line do |line|
        line = line.chomp

        # Skip front-matter metadata block.
        next if line =~ METADATA_REGEX
        next if line.start_with?("######OpenITI#")

        # Paragraph milestones (`#~~ …`) must be checked before headings, since the
        # leading `#` would otherwise match the heading regex.
        if (m = line.match(PARAGRAPH_REGEX))
          flush_paragraph(stack, current_paragraph)
          current_paragraph = strip_markup(m[1])
        elsif (m = line.match(HEADING_REGEX))
          flush_paragraph(stack, current_paragraph)
          current_paragraph = nil

          level = m[1].length
          title = strip_markup(m[2])
          node = { title: title, paragraphs: [], children: [] }

          stack.pop while stack.any? && stack.last[:level] >= level

          if stack.empty?
            tree << node
          else
            stack.last[:node][:children] << node
          end

          stack.push(level: level, node: node)
        elsif current_paragraph
          # Continuation of current paragraph (soft break or wrapped text).
          piece = strip_markup(line.sub(/\A#{Regexp.escape(SOFT_BREAK)}/, ""))
          current_paragraph = "#{current_paragraph} #{piece}".strip unless piece.empty?
        end
      end

      flush_paragraph(stack, current_paragraph)
      tree
    end

    def flush_paragraph(stack, paragraph)
      return if paragraph.nil? || paragraph.strip.empty?
      return if paragraph.strip.length < 10
      target = stack.any? ? stack.last[:node] : nil
      target[:paragraphs] << paragraph.strip if target
    end

    def strip_markup(text)
      text.to_s
        .gsub(PAGE_MARKER, "")
        .gsub(/\s+/, " ")
        .strip
    end

    def count_paragraphs(tree)
      tree.sum do |book|
        book[:paragraphs].size + book[:children].sum do |chapter|
          chapter[:paragraphs].size + chapter[:children].sum { |c| c[:paragraphs].size }
        end
      end
    end

    def create_passage(division, number, translation, text)
      passage = Passage.find_or_create_by!(division: division, number: number) do |p|
        p.position = number
      end

      TranslationSegment.find_or_create_for_range(
        translation: translation, start_passage: passage, end_passage: passage, text: text
      )
    end

    def ensure_tradition_and_corpus
      islamic = Tradition.find_or_create_by!(slug: "islamic") do |t|
        t.name = "Islamic"
      end

      @fiqh_corpus = Corpus.find_or_create_by!(slug: "fiqh") do |c|
        c.name = "Fiqh"
        c.tradition = islamic
        c.description = "Islamic jurisprudence (fiqh) and its theoretical foundations (usul al-fiqh). " \
                        "Premodern Arabic legal works from the four Sunni schools (Hanafi, Maliki, " \
                        "Shafi'i, Hanbali) and Shi'i jurisprudence. Sources from the OpenITI corpus."
      end
    end

    def ensure_translation
      Translation.find_or_create_by!(abbreviation: @translation_abbreviation, corpus: @fiqh_corpus) do |t|
        t.name = @translation_name
        t.language = "Arabic"
        t.edition_type = "original"
      end
    end
  end
end
