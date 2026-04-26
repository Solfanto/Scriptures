module Import
  class DssTranslation
    # Provides an English-translation overlay for the Dead Sea Scrolls corpus
    # by copying the corresponding canonical-Bible verse text (default: KJV)
    # into a new "DSS-EN" Translation under the DSS corpus.
    #
    # The BiblicalDSS dataset only covers fragments of the Hebrew Bible, so
    # each DSS verse maps to a single canonical reference; the KJV verse
    # text is the closest available public-domain English equivalent of
    # what the scroll preserves. Scholarly translations of the scrolls
    # (Vermes, García Martínez, etc.) remain under copyright and are not
    # imported here.

    # DSS scripture slug → canonical Bible scripture slug.
    BOOK_MAP = {
      "gen" => "genesis", "ex" => "exodus", "lev" => "leviticus",
      "num" => "numbers", "deut" => "deuteronomy", "josh" => "joshua",
      "judg" => "judges", "ruth" => "ruth", "1sam" => "1-samuel",
      "2sam" => "2-samuel", "1kgs" => "1-kings", "2kgs" => "2-kings",
      "1chr" => "1-chronicles", "2chr" => "2-chronicles", "ezra" => "ezra",
      "neh" => "nehemiah", "esth" => "esther", "job" => "job",
      "ps" => "psalms", "prov" => "proverbs", "eccl" => "ecclesiastes",
      "song" => "song-of-solomon", "isa" => "isaiah", "jer" => "jeremiah",
      "lam" => "lamentations", "ezek" => "ezekiel", "dan" => "daniel",
      "hos" => "hosea", "joel" => "joel", "amos" => "amos",
      "obad" => "obadiah", "jonah" => "jonah", "mic" => "micah",
      "nah" => "nahum", "hab" => "habakkuk", "zeph" => "zephaniah",
      "hag" => "haggai", "zech" => "zechariah", "mal" => "malachi"
    }.freeze

    def initialize(source_translation: "KJV", progress: nil)
      @source_abbreviation = source_translation
      @progress = progress
    end

    def run
      dss_corpus = Corpus.find_by(slug: "dead-sea-scrolls")
      bible_corpus = Corpus.find_by(slug: "bible")

      unless dss_corpus && bible_corpus
        puts "  DSS translation: required corpora missing (need 'dead-sea-scrolls' and 'bible')"
        return
      end

      source = Translation.find_by(abbreviation: @source_abbreviation, corpus_id: bible_corpus.id)
      unless source
        puts "  DSS translation: source translation #{@source_abbreviation} not imported"
        return
      end

      target = Translation.find_or_create_by!(corpus: dss_corpus, abbreviation: "DSS-EN") do |t|
        t.name = "DSS English (#{@source_abbreviation} alignment)"
        t.language = "English"
        t.edition_type = "devotional"
      end

      # Build a (scripture_slug, chapter_number, verse_number) → text lookup
      # for the source Bible translation. Loading the entire KJV in one
      # query keeps the per-verse import O(1) instead of O(n).
      source_lookup = build_source_lookup(source)

      passages = Passage.joins(division: :scripture)
        .where(divisions: { scriptures: { corpus_id: dss_corpus.id } })

      total = passages.count
      done = 0
      mapped = 0
      @progress&.call(0, total)

      passages.find_each do |passage|
        done += 1
        @progress&.call(done, total) if done % 500 == 0

        dss_scripture = passage.division.scripture
        bible_slug = BOOK_MAP[dss_scripture.slug]
        next unless bible_slug

        text = source_lookup.dig(bible_slug, passage.division.number, passage.number)
        next if text.blank?

        TranslationSegment.find_or_create_for_range(
          translation: target, start_passage: passage, end_passage: passage, text: text
        )
        mapped += 1
      end

      @progress&.call(total, total)
      puts "  DSS English (via #{@source_abbreviation}): #{mapped} of #{total} DSS verses aligned to Bible text"
    end

    private

    def build_source_lookup(translation)
      lookup = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = {} } }

      TranslationSegment.where(translation_id: translation.id)
        .includes(start_passage: { division: :scripture })
        .find_each do |seg|
          next unless seg.single_passage?
          passage = seg.start_passage
          division = passage.division
          scripture = division.scripture
          lookup[scripture.slug][division.number][passage.number] = seg.text
        end

      lookup
    end
  end
end
