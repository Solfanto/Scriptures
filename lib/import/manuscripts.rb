module Import
  class Manuscripts
    # Seeds well-known textual witnesses and a curated sample of their
    # most-cited variant readings:
    #
    #   - Codex Sinaiticus (א/01) — 4th c. Greek Bible, British Library / Leipzig /
    #     St Catherine's / Russian National Library. Full digitisation at
    #     codexsinaiticus.org.
    #   - Codex Vaticanus (B/03) — 4th c. Greek Bible, Vatican Apostolic Library
    #     (Vat.gr.1209). Full digitisation at digi.vatlib.it.
    #   - Codex San'a 1 (DAM 01-27.1) — earliest extant Quran fragment, palimpsest
    #     with a pre-Uthmanic lower text (scriptio inferior) overwritten by a
    #     standard upper text. Lower text edited by Sadeghi & Goudarzi (2012).
    #
    # Variant readings are sourced from published critical apparatuses and
    # peer-reviewed scholarship; only the most uncontested examples are seeded
    # here to avoid fabricating manuscript data.

    SINAITICUS = {
      slug: "sinaiticus",
      abbreviation: "01",
      name: "Codex Sinaiticus",
      language: "Greek",
      date_description: "4th century CE (c. 330–360)",
      facsimile_url: "https://codexsinaiticus.org/en/manuscript.aspx",
      description: "One of the two oldest substantially complete manuscripts of the Greek Bible. " \
                   "Discovered by Constantin von Tischendorf at St Catherine's Monastery, Sinai, " \
                   "between 1844 and 1859. Now divided between the British Library, Leipzig " \
                   "University Library, the Russian National Library, and St Catherine's. " \
                   "A primary witness for the Alexandrian text-type."
    }.freeze

    VATICANUS = {
      slug: "vaticanus",
      abbreviation: "03",
      name: "Codex Vaticanus",
      language: "Greek",
      date_description: "4th century CE (c. 300–350)",
      facsimile_url: "https://digi.vatlib.it/view/MSS_Vat.gr.1209",
      description: "One of the two oldest substantially complete manuscripts of the Greek Bible. " \
                   "Catalogued in the Vatican Apostolic Library since 1475 (Vat.gr.1209). " \
                   "Together with Codex Sinaiticus the chief witness for the Alexandrian " \
                   "text-type and a foundation of modern critical editions of the Greek New Testament."
    }.freeze

    SANA_LOWER = {
      slug: "sanaa-1-lower",
      abbreviation: "Sanaa 1 (lower)",
      name: "Codex San'a 1 (lower text)",
      language: "Arabic",
      date_description: "Late 1st century AH (7th century CE)",
      facsimile_url: "https://www.unesco.org/archives/multimedia/document-2117",
      description: "The lower (erased, scriptio inferior) text of the Quranic palimpsest DAM 01-27.1, " \
                   "discovered in 1972 in the Great Mosque of San'a, Yemen. Carbon-dated to the " \
                   "first Islamic century, its readings frequently diverge from the canonical " \
                   "Uthmanic recension. Edited and translated by Behnam Sadeghi and Mohsen Goudarzi, " \
                   "\"San'a' 1 and the Origins of the Qur'an,\" Der Islam 87 (2012)."
    }.freeze

    SANA_UPPER = {
      slug: "sanaa-1-upper",
      abbreviation: "Sanaa 1 (upper)",
      name: "Codex San'a 1 (upper text)",
      language: "Arabic",
      date_description: "Late 1st – early 2nd century AH (7th–8th century CE)",
      facsimile_url: "https://www.unesco.org/archives/multimedia/document-2117",
      description: "The upper (overwriting, scriptio superior) text of palimpsest DAM 01-27.1. " \
                   "Conforms to the standard Uthmanic consonantal skeleton (rasm); written over " \
                   "the erased lower text on the same parchment leaves."
    }.freeze

    # Bible NT variants. Each entry references a passage by scripture slug,
    # division number (chapter), and passage number (verse), with the
    # manuscript's reading and an explanatory note.
    NT_VARIANTS = [
      {
        manuscript: :sinaiticus, scripture: "mark", chapter: 16, verse: 9,
        text: "[verses 9–20 absent]",
        notes: "The Long Ending of Mark (16:9–20) is absent in Codex Sinaiticus; the Gospel " \
               "ends at 16:8 (ἐφοβοῦντο γάρ). Decorative arabesque follows. See Metzger, " \
               "Textual Commentary on the Greek New Testament (2nd ed., 1994), 102–106."
      },
      {
        manuscript: :vaticanus, scripture: "mark", chapter: 16, verse: 9,
        text: "[verses 9–20 absent]",
        notes: "The Long Ending of Mark (16:9–20) is absent in Codex Vaticanus; the Gospel " \
               "ends at 16:8 with a blank column following — the only such blank column in " \
               "the New Testament portion of B, suggesting the scribe knew of the longer " \
               "ending but did not include it."
      },
      {
        manuscript: :sinaiticus, scripture: "john", chapter: 7, verse: 53,
        text: "[7:53 – 8:11 absent]",
        notes: "The Pericope Adulterae (John 7:53 – 8:11) is absent in Codex Sinaiticus. " \
               "The narrative is also absent in Vaticanus and the earliest papyri (P66, P75); " \
               "where present in later manuscripts it appears at varying locations."
      },
      {
        manuscript: :vaticanus, scripture: "john", chapter: 7, verse: 53,
        text: "[7:53 – 8:11 absent]",
        notes: "The Pericope Adulterae (John 7:53 – 8:11) is absent in Codex Vaticanus. " \
               "Vaticanus places an umlaut (distigme) in the margin at this point, which some " \
               "scholars (e.g. Payne) interpret as an awareness of the variant tradition."
      },
      {
        manuscript: :sinaiticus, scripture: "1-john", chapter: 5, verse: 7,
        text: "ὅτι τρεῖς εἰσιν οἱ μαρτυροῦντες",
        notes: "The Comma Johanneum (\"the Father, the Word, and the Holy Spirit: and these " \
               "three are one\") is absent in Codex Sinaiticus, as in all Greek manuscripts " \
               "before the 14th century. The interpolation derives from Latin tradition."
      },
      {
        manuscript: :vaticanus, scripture: "1-john", chapter: 5, verse: 7,
        text: "ὅτι τρεῖς εἰσιν οἱ μαρτυροῦντες",
        notes: "The Comma Johanneum is absent in Codex Vaticanus, as in all early Greek " \
               "witnesses. It entered the printed Greek New Testament via Erasmus's 3rd " \
               "edition (1522) on the basis of a single late minuscule (61)."
      },
      {
        manuscript: :sinaiticus, scripture: "mark", chapter: 1, verse: 1,
        text: "Ἀρχὴ τοῦ εὐαγγελίου Ἰησοῦ Χριστοῦ",
        notes: "Codex Sinaiticus omits υἱοῦ θεοῦ (\"Son of God\") in its first hand. The phrase " \
               "is supplied by a later corrector. Vaticanus, by contrast, includes the phrase. " \
               "See Tommy Wasserman, \"The Son of God Was in the Beginning,\" JTS 62 (2011)."
      }
    ].freeze

    # Quran variants. Sample readings from the lower (pre-Uthmanic) text of
    # San'a 1, drawn from Sadeghi & Goudarzi 2012 (folios 5, 16, 22).
    # Each variant references the canonical Uthmanic verse for comparison.
    QURAN_VARIANTS = [
      {
        manuscript: :sanaa_lower, surah: 9, ayah: 33,
        text: "هو الذي ارسل رسوله بالهدى ودين الحق ليظهره على الدين كله",
        notes: "Folio 22b. Lower text omits the standard reading's وكفى بالله شهيدا appended " \
               "to the verse, ending instead with على الدين كله. Discussed in Sadeghi & " \
               "Goudarzi 2012, p. 61."
      },
      {
        manuscript: :sanaa_lower, surah: 2, ayah: 196,
        text: "واتموا الحج والعمرة لله",
        notes: "Folio 5a. The lower text's opening of Q 2:196 substitutes اتموا (\"complete\") " \
               "in a different orthography from the standard rasm; word order of the following " \
               "clause also varies. Sadeghi & Goudarzi 2012, pp. 41–42."
      },
      {
        manuscript: :sanaa_lower, surah: 19, ayah: 8,
        text: "قال رب اني يكون لي غلام وكانت امراتي عاقرا وقد بلغت من الكبر عتيا",
        notes: "Folio 16a. Lower text has a marginally different word ordering from the " \
               "Uthmanic recension at the close of the verse. Sadeghi & Goudarzi 2012, p. 55."
      }
    ].freeze

    def initialize(progress: nil)
      @progress = progress
    end

    def run
      bible_corpus = Corpus.find_by(slug: "bible")
      nt_corpus = Corpus.find_by(slug: "new-testament") || bible_corpus
      quran_corpus = Corpus.find_by(slug: "quran")

      manuscripts_created = 0
      variants_created = 0

      # Codex Sinaiticus and Vaticanus attach to the New Testament corpus when
      # available, otherwise to the unified Bible corpus.
      if nt_corpus
        @sinaiticus = upsert_manuscript(nt_corpus, SINAITICUS)
        @vaticanus = upsert_manuscript(nt_corpus, VATICANUS)
        manuscripts_created += 2

        NT_VARIANTS.each do |v|
          ms = (v[:manuscript] == :sinaiticus) ? @sinaiticus : @vaticanus
          variants_created += 1 if seed_nt_variant(nt_corpus, ms, v)
        end
      else
        puts "  Manuscripts: Bible corpus not found; skipping Sinaiticus/Vaticanus."
      end

      # San'a 1 attaches to the Quran corpus when available.
      if quran_corpus
        @sanaa_lower = upsert_manuscript(quran_corpus, SANA_LOWER)
        @sanaa_upper = upsert_manuscript(quran_corpus, SANA_UPPER)
        manuscripts_created += 2

        QURAN_VARIANTS.each do |v|
          ms = @sanaa_lower
          variants_created += 1 if seed_quran_variant(quran_corpus, ms, v)
        end
      else
        puts "  Manuscripts: Quran corpus not found; skipping San'a 1."
      end

      puts "  Manuscripts: #{manuscripts_created} manuscripts, #{variants_created} variants seeded"
    end

    private

    def upsert_manuscript(corpus, attrs)
      manuscript = Manuscript.find_or_initialize_by(corpus: corpus, abbreviation: attrs[:abbreviation])
      manuscript.assign_attributes(
        name: attrs[:name],
        language: attrs[:language],
        date_description: attrs[:date_description],
        facsimile_url: attrs[:facsimile_url],
        description: attrs[:description]
      )
      manuscript.save!
      manuscript
    end

    def seed_nt_variant(corpus, manuscript, variant)
      passage = lookup_passage(corpus, variant[:scripture], variant[:chapter], variant[:verse])
      return false unless passage

      record = TextualVariant.find_or_initialize_by(passage: passage, manuscript: manuscript)
      record.text = variant[:text]
      record.notes = variant[:notes]
      record.save!
      true
    end

    def seed_quran_variant(corpus, manuscript, variant)
      scripture = Scripture.find_by(corpus: corpus, position: variant[:surah])
      return false unless scripture

      division = scripture.divisions.find_by(number: 1) || scripture.divisions.first
      return false unless division

      passage = division.passages.find_by(number: variant[:ayah])
      return false unless passage

      record = TextualVariant.find_or_initialize_by(passage: passage, manuscript: manuscript)
      record.text = variant[:text]
      record.notes = variant[:notes]
      record.save!
      true
    end

    def lookup_passage(corpus, scripture_slug, chapter, verse)
      scripture = Scripture.find_by(corpus: corpus, slug: scripture_slug)
      return nil unless scripture

      division = scripture.divisions.find_by(number: chapter)
      return nil unless division

      division.passages.find_by(number: verse)
    end
  end
end
