module Import
  class Sblgnt
    # MorphGNT book number => [name, NT canonical position]
    BOOKS = {
      "61" => [ "Matthew", 1 ],
      "62" => [ "Mark", 2 ],
      "63" => [ "Luke", 3 ],
      "64" => [ "John", 4 ],
      "65" => [ "Acts", 5 ],
      "66" => [ "Romans", 6 ],
      "67" => [ "1 Corinthians", 7 ],
      "68" => [ "2 Corinthians", 8 ],
      "69" => [ "Galatians", 9 ],
      "70" => [ "Ephesians", 10 ],
      "71" => [ "Philippians", 11 ],
      "72" => [ "Colossians", 12 ],
      "73" => [ "1 Thessalonians", 13 ],
      "74" => [ "2 Thessalonians", 14 ],
      "75" => [ "1 Timothy", 15 ],
      "76" => [ "2 Timothy", 16 ],
      "77" => [ "Titus", 17 ],
      "78" => [ "Philemon", 18 ],
      "79" => [ "Hebrews", 19 ],
      "80" => [ "James", 20 ],
      "81" => [ "1 Peter", 21 ],
      "82" => [ "2 Peter", 22 ],
      "83" => [ "1 John", 23 ],
      "84" => [ "2 John", 24 ],
      "85" => [ "3 John", 25 ],
      "86" => [ "Jude", 26 ],
      "87" => [ "Revelation", 27 ]
    }.freeze

    def initialize(directory:)
      @directory = directory
    end

    def run
      ensure_corpus
      translation = Translation.find_or_create_by!(abbreviation: "SBLGNT", corpus: @nt_corpus) do |t|
        t.name = "SBL Greek New Testament"
        t.language = "Greek"
      end

      files = Dir.glob(@directory.join("*.txt")).sort
      puts "Importing SBLGNT — #{files.size} books"

      total_passages = 0

      files.each do |file|
        book_code = File.basename(file).split("-").first
        book_name, position = BOOKS[book_code]
        next unless book_name

        scripture = Scripture.find_or_create_by!(corpus: @nt_corpus, slug: slugify(book_name)) do |s|
          s.name = book_name
          s.position = position
        end

        # Parse word-level rows and assemble verse text
        verses = {}
        File.readlines(file, chomp: true).each do |line|
          parts = line.split(" ")
          next if parts.size < 4

          ref = parts[0]           # BBCCVV
          text_word = parts[3]     # word with punctuation

          chapter = ref[2..3].to_i
          verse = ref[4..5].to_i
          key = [ chapter, verse ]

          verses[key] ||= []
          verses[key] << text_word
        end

        verses.each do |(chapter, verse_num), words|
          division = Division.find_or_create_by!(scripture: scripture, number: chapter) do |d|
            d.name = "Chapter #{chapter}"
            d.position = chapter
          end

          passage = Passage.find_or_create_by!(division: division, number: verse_num) do |p|
            p.position = verse_num
          end

          assembled_text = words.join(" ")
          PassageTranslation.find_or_create_by!(passage: passage, translation: translation) do |pt|
            pt.text = assembled_text
          end

          total_passages += 1
        end

        print "."
      end

      puts "\n  SBLGNT: #{total_passages} passage translations imported"
    end

    private

    def ensure_corpus
      christian = Tradition.find_or_create_by!(slug: "christian") do |t|
        t.name = "Christian"
      end

      @nt_corpus = Corpus.find_or_create_by!(slug: "new-testament") do |c|
        c.name = "New Testament"
        c.tradition = christian
      end
    end

    def slugify(name)
      name.downcase.gsub(/\s+/, "-").gsub(/[^a-z0-9\-]/, "")
    end
  end
end
