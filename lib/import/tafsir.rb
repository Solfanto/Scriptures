require "json"

module Import
  class Tafsir
    # Imports tafsir (Quranic exegesis) from spa5k/tafsir_api JSON files
    # as Commentary records linked to existing Quran passages.
    #
    # Each surah has a JSON file with structure:
    #   { "ayahs": [{ "ayah": 1, "surah": 1, "text": "..." }, ...] }
    #
    # Mapping:
    #   Tafsir entry → Commentary (passage_id from Quran, author, source, commentary_type)

    EDITIONS = {
      "en-tafisr-ibn-kathir" => {
        author: "Ibn Kathir",
        name: "Tafsir Ibn Kathir (abridged)",
        language: "English",
        commentary_type: "critical"
      },
      "en-al-jalalayn" => {
        author: "Al-Jalalayn",
        name: "Tafsir al-Jalalayn",
        language: "English",
        commentary_type: "critical"
      },
      "ar-tafsir-al-tabari" => {
        author: "Al-Tabari",
        name: "Tafsir al-Tabari",
        language: "Arabic",
        commentary_type: "critical"
      }
    }.freeze

    def initialize(directory:, edition:)
      @directory = Pathname.new(directory)
      @edition = edition
      @edition_info = EDITIONS[edition] || raise("Unknown edition: #{edition}. Available: #{EDITIONS.keys.join(', ')}")
    end

    def run
      puts "Importing tafsir: #{@edition_info[:name]} (#{@edition_info[:language]})"

      quran_corpus = Corpus.find_by!(slug: "quran")

      # Build lookup: surah_number → { ayah_number → passage }
      passage_lookup = build_passage_lookup(quran_corpus)

      if passage_lookup.empty?
        puts "  ERROR: No Quran passages found. Import the Quran first (rake import:quran_tanzil)."
        return
      end

      total = 0
      skipped = 0

      (1..114).each do |surah_num|
        file = @directory.join("#{surah_num}.json")
        next unless file.exist?

        data = JSON.parse(File.read(file))
        ayahs = data["ayahs"] || []

        ayahs.each do |entry|
          ayah_num = entry["ayah"]
          text = entry["text"].to_s.strip
          next if text.blank?

          passage = passage_lookup.dig(surah_num, ayah_num)
          unless passage
            skipped += 1
            next
          end

          Commentary.find_or_create_by!(
            passage: passage,
            author: @edition_info[:author],
            source: @edition_info[:name]
          ) do |c|
            c.body = text
            c.commentary_type = @edition_info[:commentary_type]
          end

          total += 1
        end
      end

      puts "  #{@edition_info[:name]}: #{total} commentaries imported (#{skipped} skipped — no matching passage)"
    end

    private

    def build_passage_lookup(quran_corpus)
      lookup = {}

      quran_corpus.scriptures.includes(divisions: :passages).find_each do |scripture|
        surah_num = scripture.position
        next unless surah_num

        scripture.divisions.each do |division|
          division.passages.each do |passage|
            lookup[surah_num] ||= {}
            lookup[surah_num][passage.number] = passage
          end
        end
      end

      lookup
    end
  end
end
