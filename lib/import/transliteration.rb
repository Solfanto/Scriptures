require "transliterate"

module Import
  class Transliteration
    # Generates a transliterated Translation by passing every segment of an
    # existing original-language Translation through a Latin-script
    # transliterator. The result lives in the same corpus as a separate
    # Translation so it is selectable in the parallel viewer and search.

    LANG_TO_METHOD = {
      "Greek"  => :greek,
      "Hebrew" => :hebrew,
      "Arabic" => :arabic
    }.freeze

    def initialize(translation:, abbreviation:, name:, language: nil, progress: nil)
      @source = translation
      @abbreviation = abbreviation
      @name = name
      @language = language || @source.language
      @progress = progress

      @method = LANG_TO_METHOD[@language] || raise("Unsupported transliteration language: #{@language}")
    end

    def run
      target = Translation.find_or_create_by!(corpus: @source.corpus, abbreviation: @abbreviation) do |t|
        t.name = @name
        t.language = "#{@language} (Latin transliteration)"
        t.edition_type = @source.edition_type
      end

      segments = TranslationSegment.where(translation_id: @source.id)
      total = segments.count
      done = 0

      @progress&.call(0, total)

      segments.find_each do |seg|
        text = Transliterate.public_send(@method, seg.text)
        next if text.strip.empty?

        TranslationSegment.find_or_create_for_range(
          translation: target,
          start_passage: seg.start_passage,
          end_passage: seg.end_passage,
          text: text
        )

        done += 1
        @progress&.call(done, total) if done % 200 == 0
      end

      @progress&.call(total, total)
      puts "  #{@source.abbreviation} → #{@abbreviation}: #{done} segments transliterated (#{@language})"
    end
  end
end
