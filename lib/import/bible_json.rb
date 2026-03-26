require "json"

module Import
  class BibleJson
    # Mapping from scrollmapper JSON book names to corpus assignment.
    # Old Testament books belong to the "bible" corpus, New Testament to "new-testament".
    NT_BOOKS = Set.new(%w[
      Matthew Mark Luke John Acts Romans
      1\ Corinthians 2\ Corinthians Galatians Ephesians Philippians Colossians
      1\ Thessalonians 2\ Thessalonians 1\ Timothy 2\ Timothy Titus Philemon
      Hebrews James 1\ Peter 2\ Peter 1\ John 2\ John 3\ John Jude Revelation
    ]).freeze

    def initialize(file:, abbreviation:, name:, language:)
      @file = file
      @abbreviation = abbreviation
      @name = name
      @language = language
    end

    def run
      data = JSON.parse(File.read(@file))
      books = data["books"]

      puts "Importing #{@abbreviation} (#{@name}) — #{books.size} books"

      ensure_traditions_and_corpora
      translation_ot = ensure_translation(@bible_corpus)
      translation_nt = ensure_translation(@nt_corpus)

      total_passages = 0

      books.each_with_index do |book, book_index|
        book_name = book["name"]
        corpus = nt_book?(book_name) ? @nt_corpus : @bible_corpus
        translation = nt_book?(book_name) ? translation_nt : translation_ot

        scripture = Scripture.find_or_create_by!(corpus: corpus, slug: slugify(book_name)) do |s|
          s.name = book_name
          s.position = book_index + 1
        end

        book["chapters"].each do |chapter_data|
          chapter_num = chapter_data["chapter"]

          division = Division.find_or_create_by!(scripture: scripture, number: chapter_num) do |d|
            d.name = "Chapter #{chapter_num}"
            d.position = chapter_num
          end

          chapter_data["verses"].each do |verse_data|
            verse_num = verse_data["verse"]
            text = verse_data["text"]&.strip

            next if text.blank?

            passage = Passage.find_or_create_by!(division: division, number: verse_num) do |p|
              p.position = verse_num
            end

            PassageTranslation.find_or_create_by!(passage: passage, translation: translation) do |pt|
              pt.text = text
            end

            total_passages += 1
          end
        end

        print "."
      end

      puts "\n  #{@abbreviation}: #{total_passages} passage translations imported"
    end

    private

    def ensure_traditions_and_corpora
      jewish = Tradition.find_or_create_by!(slug: "jewish") do |t|
        t.name = "Jewish"
      end

      christian = Tradition.find_or_create_by!(slug: "christian") do |t|
        t.name = "Christian"
      end

      @bible_corpus = Corpus.find_or_create_by!(slug: "bible") do |c|
        c.name = "Bible"
        c.tradition = jewish
        c.description = "The Hebrew Bible / Old Testament."
      end

      @nt_corpus = Corpus.find_or_create_by!(slug: "new-testament") do |c|
        c.name = "New Testament"
        c.tradition = christian
        c.description = "The Christian New Testament, 27 books composed in Koine Greek."
      end
    end

    def ensure_translation(corpus)
      Translation.find_or_create_by!(abbreviation: @abbreviation, corpus: corpus) do |t|
        t.name = @name
        t.language = @language
      end
    end

    def nt_book?(name)
      NT_BOOKS.include?(name)
    end

    def slugify(name)
      name.downcase.gsub(/\s+/, "-").gsub(/[^a-z0-9\-]/, "")
    end
  end
end
