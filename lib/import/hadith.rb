require "json"

module Import
  class Hadith
    # Imports hadith collections from AhmedBaset/hadith-json by_book JSON format.
    #
    # Each JSON file represents one collection (e.g. Sahih al-Bukhari) with structure:
    #   { id, metadata: { length, arabic: { title, author }, english: { title, author } },
    #     chapters: [{ id, bookId, arabic, english }],
    #     hadiths: [{ id, idInBook, chapterId, bookId, arabic, english: { narrator, text } }] }
    #
    # Mapping:
    #   Corpus "Hadith" → Scripture (one per collection) → Division (one per chapter/kitab)
    #   → Passage (one per hadith) → TranslationSegment (Arabic + English)

    COLLECTIONS = {
      # The nine major books
      "bukhari" => { slug: "sahih-al-bukhari", position: 1 },
      "muslim" => { slug: "sahih-muslim", position: 2 },
      "abudawud" => { slug: "sunan-abu-dawud", position: 3 },
      "tirmidhi" => { slug: "jami-at-tirmidhi", position: 4 },
      "nasai" => { slug: "sunan-an-nasai", position: 5 },
      "ibnmajah" => { slug: "sunan-ibn-majah", position: 6 },
      "malik" => { slug: "muwatta-malik", position: 7 },
      "ahmed" => { slug: "musnad-ahmad", position: 8 },
      "darimi" => { slug: "sunan-ad-darimi", position: 9 },
      # Forty hadith collections
      "nawawi40" => { slug: "forty-hadith-nawawi", position: 10 },
      "qudsi40" => { slug: "forty-hadith-qudsi", position: 11 },
      "shahwaliullah40" => { slug: "forty-hadith-shah-waliullah", position: 12 },
      # Other books
      "aladab_almufrad" => { slug: "al-adab-al-mufrad", position: 13 },
      "bulugh_almaram" => { slug: "bulugh-al-maram", position: 14 },
      "mishkat_almasabih" => { slug: "mishkat-al-masabih", position: 15 },
      "riyad_assalihin" => { slug: "riyad-as-salihin", position: 16 },
      "shamail_muhammadiyah" => { slug: "shamail-muhammadiyah", position: 17 }
    }.freeze

    def initialize(file:)
      @file = Pathname.new(file)
    end

    def run
      data = JSON.parse(File.read(@file))
      metadata = data["metadata"]
      title_en = metadata.dig("english", "title") || @file.basename(".json").to_s.titleize
      title_ar = metadata.dig("arabic", "title") || title_en

      puts "Importing #{title_en} — #{metadata['length']} hadiths"

      ensure_tradition_and_corpus

      collection_key = @file.basename(".json").to_s
      collection_info = COLLECTIONS[collection_key] || { slug: collection_key, position: COLLECTIONS.size + 1 }

      scripture = Scripture.find_or_create_by!(corpus: @hadith_corpus, slug: collection_info[:slug]) do |s|
        s.name = title_en
        s.position = collection_info[:position]
        s.description = "#{title_en} (#{title_ar}). Author: #{metadata.dig('english', 'author') || 'Unknown'}."
      end

      arabic_translation = ensure_translation("HAR", "Hadith Arabic", "Arabic")
      english_translation = ensure_translation("HEN", "Hadith English", "English")

      # Build chapter lookup: chapterId → chapter metadata
      chapters = {}
      (data["chapters"] || []).each do |ch|
        chapters[ch["id"]] = ch
      end

      # Create divisions for each chapter
      divisions = {}
      chapters.each do |chapter_id, ch|
        division = Division.find_or_create_by!(scripture: scripture, number: chapter_id) do |d|
          d.name = ch["english"].presence || ch["arabic"].presence || "Chapter #{chapter_id}"
          d.position = chapter_id
        end
        divisions[chapter_id] = division
      end

      total = 0
      hadiths = data["hadiths"] || []

      hadiths.each do |h|
        chapter_id = h["chapterId"]

        # Ensure division exists even if not in chapters array
        division = divisions[chapter_id] ||= begin
          Division.find_or_create_by!(scripture: scripture, number: chapter_id) do |d|
            d.name = "Chapter #{chapter_id}"
            d.position = chapter_id
          end
        end

        passage_number = h["idInBook"]
        passage = Passage.find_or_create_by!(division: division, number: passage_number) do |p|
          p.position = passage_number
        end

        # Arabic text
        arabic_text = h["arabic"]
        if arabic_text.present?
          TranslationSegment.find_or_create_for_range(
            translation: arabic_translation, start_passage: passage, end_passage: passage, text: arabic_text.strip
          )
        end

        # English text (narrator + text combined)
        english_data = h["english"]
        if english_data.is_a?(Hash)
          narrator = english_data["narrator"].to_s.strip
          text = english_data["text"].to_s.strip
          english_text = [ narrator, text ].reject(&:blank?).join(" ")
        else
          english_text = english_data.to_s.strip
        end

        if english_text.present?
          TranslationSegment.find_or_create_for_range(
            translation: english_translation, start_passage: passage, end_passage: passage, text: english_text
          )
        end

        total += 1
      end

      puts "  #{title_en}: #{total} hadiths imported (#{divisions.size} chapters)"
    end

    private

    def ensure_tradition_and_corpus
      islamic = Tradition.find_or_create_by!(slug: "islamic") do |t|
        t.name = "Islamic"
      end

      @hadith_corpus = Corpus.find_or_create_by!(slug: "hadith") do |c|
        c.name = "Hadith"
        c.tradition = islamic
        c.description = "The collected sayings, actions, and approvals of the Prophet Muhammad, transmitted through chains of narrators. The six canonical collections (Kutub al-Sittah) plus supplementary compilations."
      end
    end

    def ensure_translation(abbreviation, name, language)
      Translation.find_or_create_by!(abbreviation: abbreviation, corpus: @hadith_corpus) do |t|
        t.name = name
        t.language = language
      end
    end
  end
end
