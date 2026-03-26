require "json"

module Import
  class Suttacentral
    def initialize(pali_dir:, translation_dir: nil, translation_abbreviation: nil, translation_name: nil, scripture_name:, scripture_slug:)
      @pali_dir = pali_dir
      @translation_dir = translation_dir
      @translation_abbreviation = translation_abbreviation
      @translation_name = translation_name
      @scripture_name = scripture_name
      @scripture_slug = scripture_slug
    end

    def run
      ensure_tradition_and_corpus

      scripture = Scripture.find_or_create_by!(corpus: @pali_corpus, slug: @scripture_slug) do |s|
        s.name = @scripture_name
        s.position = Scripture.where(corpus: @pali_corpus).count + 1
      end

      pali_translation = Translation.find_or_create_by!(abbreviation: "PLI", corpus: @pali_corpus) do |t|
        t.name = "Pali Canon (Mahāsaṅgīti)"
        t.language = "Pali"
      end

      en_translation = nil
      if @translation_dir && @translation_abbreviation
        en_translation = Translation.find_or_create_by!(abbreviation: @translation_abbreviation, corpus: @pali_corpus) do |t|
          t.name = @translation_name
          t.language = "English"
        end
      end

      # Parse all Pali files, assembling verse text from segments
      pali_verses = parse_verses(Dir.glob(@pali_dir.join("*.json")).sort)
      en_verses = en_translation ? parse_verses(Dir.glob(@translation_dir.join("*.json")).sort) : {}

      puts "Importing #{@scripture_name} — #{pali_verses.size} verses"

      # Group by the chapter/vagga implied by verse ranges
      # Dhammapada: verses 1-20 = Chapter 1, etc.
      total = 0

      # Use a single division for the whole scripture (Dhammapada has vaggas but
      # the verse numbering is continuous 1-423)
      division = Division.find_or_create_by!(scripture: scripture, number: 1) do |d|
        d.name = @scripture_name
        d.position = 1
      end

      pali_verses.each do |verse_num, pali_text|
        passage = Passage.find_or_create_by!(division: division, number: verse_num) do |p|
          p.position = verse_num
        end

        PassageTranslation.find_or_create_by!(passage: passage, translation: pali_translation) do |pt|
          pt.text = pali_text
        end

        if en_translation && en_verses[verse_num]
          PassageTranslation.find_or_create_by!(passage: passage, translation: en_translation) do |pt|
            pt.text = en_verses[verse_num]
          end
        end

        total += 1
      end

      puts "  #{@scripture_name}: #{total} passages imported"
    end

    private

    def ensure_tradition_and_corpus
      buddhist = Tradition.find_or_create_by!(slug: "buddhist") do |t|
        t.name = "Buddhist"
        t.description = "The Buddhist scriptural tradition including Pali Canon, Mahayana sutras, and Vajrayana texts."
      end

      @pali_corpus = Corpus.find_or_create_by!(slug: "pali-canon") do |c|
        c.name = "Pali Canon"
        c.tradition = buddhist
        c.description = "The Tipiṭaka, the canonical collection of Theravāda Buddhism, preserved in Pali."
      end
    end

    def parse_verses(files)
      verses = {}

      files.each do |file|
        data = JSON.parse(File.read(file))

        data.each do |segment_id, text|
          # Segment IDs: "dhp1:1", "dhp1:2", "dhp2:0.1" (headers), etc.
          match = segment_id.match(/\Adhp(\d+):(\d+)\z/)
          next unless match # Skip headers (x:0.y)

          verse_num = match[1].to_i
          line_num = match[2].to_i
          next if line_num == 0 # Skip verse-level headers

          verses[verse_num] ||= []
          verses[verse_num] << text.strip
        end
      end

      # Join lines into verse text
      verses.transform_values { |lines| lines.join(" ").squeeze(" ").strip }
    end
  end
end
