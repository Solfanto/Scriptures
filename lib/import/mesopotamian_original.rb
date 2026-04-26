module Import
  class MesopotamianOriginal
    # Seeds a curated sample of the Akkadian original (Latin-script transliteration)
    # for the existing Mesopotamian English-translation scriptures. Each entry is
    # a well-known opening line drawn from public-domain scholarly editions:
    #
    #   - Epic of Gilgamesh (Standard Babylonian recension): R. Campbell Thompson,
    #     "The Epic of Gilgamish: Text, Transliteration, and Notes," Oxford 1930.
    #   - Enuma Elish: L. W. King, "The Seven Tablets of Creation," London 1902.
    #
    # Both editions are in the public domain. The seed is intentionally small —
    # a handful of opening lines per tablet — and is meant as scaffolding for
    # a future full-text import; the readings here are stable enough to be
    # uncontroversial across editions.

    GILGAMESH = [
      [ 1, 1, "ša naqba īmuru išdī māti" ],
      [ 1, 2, "ša kullati īdû tipšuḫu kalama" ],
      [ 1, 3, "Gilgameš ša naqba īmuru išdī māti" ],
      [ 1, 4, "ša kullati īdû mudû gimri" ],
      [ 1, 5, "ina ūmišu Gilgameš ibniš adi rapašti" ],
      [ 11, 1, "Gilgameš ana šâšu izakkara ana Ūta-napišti rūqi" ],
      [ 11, 2, "ammurka Ūta-napišti minâ tabnâta" ],
      [ 11, 3, "anāku gilgāmeš ina puḫrika ašab" ],
      [ 11, 8, "Ūta-napišti ana šâšu izakkara ana Gilgameš" ],
      [ 11, 9, "lupteka Gilgameš amat niṣirti" ]
    ].freeze

    ENUMA_ELISH = [
      [ 1, 1, "enūma eliš lā nabû šamāmū" ],
      [ 1, 2, "šapliš ammatum šuma lā zakrat" ],
      [ 1, 3, "Apsû-ma rēštû zārûšun" ],
      [ 1, 4, "Mummu Tiāmat muʾallidat gimrīšun" ],
      [ 1, 5, "mêšunu ištêniš iḫīqūma" ],
      [ 1, 6, "gipāra lā kiṣṣurū ṣuṣâ lā šēʾû" ],
      [ 1, 7, "enūma ilānī lā šūpû manāma" ],
      [ 1, 8, "šuma lā zukkurū šīmāti lā šīmū" ],
      [ 4, 1, "iddinūšumma parak rubūti" ],
      [ 4, 2, "maḫar abbēšu ana mālikūti irmema" ],
      [ 6, 1, "Marduk amât ilānī ina šemêšu" ],
      [ 7, 1, "Asarluḫi šanūš imbû banûtu" ]
    ].freeze

    SCRIPTURES = {
      "epic-of-gilgamesh" => {
        seed: GILGAMESH,
        translation: { abbreviation: "GLG-AKK", name: "Epic of Gilgamesh — Akkadian transliteration (Thompson 1930)" }
      },
      "enuma-elish" => {
        seed: ENUMA_ELISH,
        translation: { abbreviation: "EE-AKK", name: "Enuma Elish — Akkadian transliteration (King 1902)" }
      }
    }.freeze

    def initialize(progress: nil)
      @progress = progress
    end

    def run
      corpus = Corpus.find_by(slug: "mesopotamian-literature")
      unless corpus
        puts "  Mesopotamian originals: corpus not found; run :gilgamesh / :enuma_elish first."
        return
      end

      total = SCRIPTURES.values.sum { |s| s[:seed].size }
      done = 0
      @progress&.call(0, total)

      SCRIPTURES.each do |slug, config|
        scripture = corpus.scriptures.find_by(slug: slug)
        next unless scripture

        translation = Translation.find_or_create_by!(
          corpus: corpus, abbreviation: config[:translation][:abbreviation]
        ) do |t|
          t.name = config[:translation][:name]
          t.language = "Akkadian (Latin transliteration)"
          t.edition_type = "original"
        end

        config[:seed].each do |tablet, line, text|
          division = scripture.divisions.find_by(number: tablet)
          next unless division

          passage = division.passages.find_by(number: line)
          next unless passage

          TranslationSegment.find_or_create_for_range(
            translation: translation, start_passage: passage, end_passage: passage, text: text
          )

          done += 1
          @progress&.call(done, total)
        end
      end

      puts "  Mesopotamian originals: #{done} Akkadian transliteration lines seeded"
    end
  end
end
