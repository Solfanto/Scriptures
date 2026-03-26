require "json"

module Import
  class StrongsLexicon
    def initialize(file:, language:)
      @file = file
      @language = language
    end

    def run
      raw = File.read(@file)
      # Extract the JSON object from between the first { and last }
      start = raw.index("{")
      stop = raw.rindex("}")
      json_str = raw[start..stop]
      data = JSON.parse(json_str)

      puts "Importing Strong's #{@language} lexicon — #{data.size} entries"

      total = 0

      data.each do |strongs_number, entry|
        LexiconEntry.find_or_create_by!(strongs_number: strongs_number) do |le|
          le.lemma = entry["lemma"] || ""
          le.language = @language
          le.transliteration = entry["xlit"]
          le.definition = [
            entry["strongs_def"],
            entry["derivation"] ? "Derivation: #{entry['derivation']}" : nil
          ].compact.join(" ")
          le.morphology_label = entry["kjv_def"]
        end

        total += 1
      end

      puts "  #{@language}: #{total} lexicon entries imported"
    end
  end
end
