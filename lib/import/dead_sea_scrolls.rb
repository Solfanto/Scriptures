require "json"

module Import
  class DeadSeaScrolls
    def initialize(file:, progress: nil)
      @file = file
      @progress = progress
    end

    def run
      data = JSON.parse(File.read(@file))

      puts "Importing Dead Sea Scrolls — #{data.size} manuscripts"

      ensure_tradition_and_corpus

      total_passages = 0
      total_manuscripts = 0

      @progress&.call(0, data.size)

      data.each_with_index do |scroll_data, scroll_idx|
        scroll_name = scroll_data["scroll"]
        verses = scroll_data["verses"]
        next if verses.empty?

        manuscript = Manuscript.find_or_create_by!(abbreviation: scroll_name, corpus: @dss_corpus) do |m|
          m.name = scroll_name
          m.language = "Hebrew"
          m.description = "Dead Sea Scroll manuscript #{scroll_name}."
        end
        total_manuscripts += 1

        translation = Translation.find_or_create_by!(abbreviation: scroll_name, corpus: @dss_corpus) do |t|
          t.name = "#{scroll_name} transcription"
          t.language = "Hebrew"
        end

        verses.each do |ref, text|
          next if text.blank?

          book, chapter_verse = parse_reference(ref)
          next unless book && chapter_verse

          chapter, verse_num = chapter_verse
          scripture = find_or_create_scripture(book)
          next unless scripture

          division = Division.find_or_create_by!(scripture: scripture, number: chapter) do |d|
            d.name = "Chapter #{chapter}"
            d.position = chapter
          end

          passage = Passage.find_or_create_by!(division: division, number: verse_num) do |p|
            p.position = verse_num
          end

          TranslationSegment.find_or_create_for_range(
            translation: translation, start_passage: passage, end_passage: passage, text: text.strip
          )

          TextualVariant.find_or_create_by!(passage: passage, manuscript: manuscript) do |v|
            v.text = text.strip
            v.notes = "Transcription from #{scroll_name}."
          end

          total_passages += 1
        end

        @progress&.call(scroll_idx + 1, data.size)
      end

      puts "\n  Dead Sea Scrolls: #{total_manuscripts} manuscripts, #{total_passages} passage variants imported"
    end

    private

    def ensure_tradition_and_corpus
      tradition = Tradition.find_or_create_by!(slug: "jewish") do |t|
        t.name = "Jewish"
      end

      @dss_corpus = Corpus.find_or_create_by!(slug: "dead-sea-scrolls") do |c|
        c.name = "Dead Sea Scrolls"
        c.tradition = tradition
        c.description = "Manuscripts discovered in the Judaean Desert (1947–1956), dating from the 3rd century BCE to the 1st century CE. Includes the oldest known biblical manuscripts and sectarian texts."
      end

      # Also reference the Bible corpus for linking passages
      @bible_corpus = Corpus.find_by(slug: "bible")
    end

    def find_or_create_scripture(book_name)
      Scripture.find_or_create_by!(corpus: @dss_corpus, slug: slugify(book_name)) do |s|
        s.name = book_name
        s.position = Scripture.where(corpus: @dss_corpus).count + 1
      end
    end

    BOOK_PATTERN = /\A(.+?)\s+(\d+):(\d+)\z/

    def parse_reference(ref)
      match = ref.match(BOOK_PATTERN)
      return nil unless match

      book = match[1]
      chapter = match[2].to_i
      verse = match[3].to_i
      [ book, [ chapter, verse ] ]
    end

    def slugify(name)
      name.downcase.gsub(/\s+/, "-").gsub(/[^a-z0-9\-]/, "")
    end
  end
end
