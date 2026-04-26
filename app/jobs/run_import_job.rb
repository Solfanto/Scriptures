class RunImportJob < ApplicationJob
  queue_as :default

  class CancelledError < StandardError; end

  def perform(key, import_run: nil)
    import_run ||= ImportRun.create!(key: key)
    import_run.update!(status: "running", started_at: Time.current)

    @import_run = import_run

    # Download source files for this importer before running
    DownloadSourcesJob.new.perform(key)

    count_before = total_record_count
    run_importer(key)
    records_created = total_record_count - count_before

    import_run.update!(status: "completed", completed_at: Time.current, records_count: records_created)
  rescue CancelledError
    # Already marked as cancelled by cancel! — just record the count
    records_created = total_record_count - (count_before || total_record_count)
    import_run&.update_columns(records_count: records_created)
  rescue => e
    import_run&.update!(status: "failed", completed_at: Time.current, error_message: e.message)
    raise
  end

  private

  def run_importer(key)
    cb = progress_callback
    case key
    when "all"           then run_all
    # Bible translations from scrollmapper JSON format
    when "bible_kjv"     then Import::BibleJson.new(file: source("kjv.json"), abbreviation: "KJV", name: "King James Version", language: "English", progress: cb).run
    when "bible_asv"     then Import::BibleJson.new(file: source("asv.json"), abbreviation: "ASV", name: "American Standard Version", language: "English", progress: cb).run
    when "bible_ylt"     then Import::BibleJson.new(file: source("ylt.json"), abbreviation: "YLT", name: "Young's Literal Translation", language: "English", progress: cb).run
    when "bible_darby"   then Import::BibleJson.new(file: source("darby.json"), abbreviation: "DBY", name: "Darby Translation", language: "English", progress: cb).run
    # Quran from Tanzil pipe-delimited text format
    when "quran_arabic"  then Import::QuranTanzil.new(file: source("quran_arabic.txt"), abbreviation: "QAR", name: "Quran (Simple Arabic)", language: "Arabic", progress: cb).run
    when "quran_sahih"   then Import::QuranTanzil.new(file: source("quran_sahih.txt"), abbreviation: "SAH", name: "Sahih International", language: "English", progress: cb).run
    when "quran_yusufali" then Import::QuranTanzil.new(file: source("quran_yusufali.txt"), abbreviation: "YAL", name: "Yusuf Ali", language: "English", progress: cb).run
    when "quran_pickthall" then Import::QuranTanzil.new(file: source("quran_pickthall.txt"), abbreviation: "PKT", name: "Pickthall", language: "English", progress: cb).run
    # Tafsir (Quranic exegesis) from spa5k/tafsir_api JSON files
    when "tafsir"        then run_tafsir(cb)
    # SBLGNT Greek New Testament from MorphGNT word-level files
    when "sblgnt"        then Import::Sblgnt.new(directory: source("sblgnt"), progress: cb).run
    # SuttaCentral bilara-data (Pali + English)
    when "suttacentral"  then run_suttacentral(cb)
    # Hadith collections from AhmedBaset/hadith-json by_book JSON format
    when "hadith"        then run_hadith(cb)
    # Dead Sea Scrolls from BiblicalDSS JSON
    when "dead_sea_scrolls" then Import::DeadSeaScrolls.new(file: source("biblical_dss.json"), progress: cb).run
    # Sira (prophetic biography) from Internet Archive DjVu text
    when "sira" then Import::Sira.new(file: source("sira/sirat_ibn_hisham.txt"), progress: cb).run
    # Strong's lexicon from OpenScriptures JS format
    when "strongs_hebrew" then Import::StrongsLexicon.new(file: source("strongs_hebrew.js"), language: "Hebrew", progress: cb).run
    when "strongs_greek" then Import::StrongsLexicon.new(file: source("strongs_greek.js"), language: "Greek", progress: cb).run
    # Mesopotamian texts from Internet Archive DjVu text
    when "gilgamesh" then Import::Mesopotamian.new(
      file: source("mesopotamian/gilgamesh_thompson.txt"),
      scripture_name: "Epic of Gilgamesh",
      scripture_slug: "epic-of-gilgamesh",
      scripture_description: "The oldest surviving great work of literature, composed in Akkadian. " \
                             "Twelve tablets recounting the deeds of Gilgamesh, king of Uruk. " \
                             "Standard Babylonian version from the library of Ashurbanipal (7th c. BCE).",
      translation_abbreviation: "THO", translation_name: "R. Campbell Thompson (1928)",
      progress: cb
    ).run
    when "enuma_elish" then Import::Mesopotamian.new(
      file: source("mesopotamian/enuma_elish_budge.txt"),
      scripture_name: "Enuma Elish",
      scripture_slug: "enuma-elish",
      scripture_description: "The Babylonian creation epic, composed in Akkadian on seven tablets. " \
                             "Recounts Marduk's victory over Tiamat and the creation of the world. " \
                             "Recited during the New Year festival (Akitu) in Babylon.",
      translation_abbreviation: "BDG", translation_name: "E.A. Wallis Budge (1921)",
      progress: cb
    ).run
    # Celtic texts from Project Gutenberg plain text
    when "mabinogion" then Import::Celtic.new(
      file: source("celtic/mabinogion_guest.txt"),
      scripture_name: "The Mabinogion",
      scripture_slug: "mabinogion",
      scripture_description: "A collection of eleven Welsh prose tales drawn from medieval manuscripts, " \
                             "the Red Book of Hergest and the White Book of Rhydderch. " \
                             "Includes the Four Branches, Arthurian romances, and independent tales.",
      translation_abbreviation: "GUE", translation_name: "Lady Charlotte Guest (1849)",
      progress: cb
    ).run
    when "mabinogion_welsh" then Import::Celtic.new(
      file: source("celtic/mabinogion_red_book.txt"),
      scripture_name: "The Mabinogion",
      scripture_slug: "mabinogion",
      scripture_description: "A collection of eleven Welsh prose tales drawn from medieval manuscripts, " \
                             "the Red Book of Hergest and the White Book of Rhydderch. " \
                             "Includes the Four Branches, Arthurian romances, and independent tales.",
      translation_abbreviation: "RHE", translation_name: "Rhŷs & Evans, Red Book of Hergest (1887)",
      translation_language: "Middle Welsh", edition_type: "original",
      progress: cb
    ).run
    when "tain" then Import::Celtic.new(
      file: source("celtic/tain_dunn.txt"),
      scripture_name: "Táin Bó Cúailnge",
      scripture_slug: "tain-bo-cuailnge",
      scripture_description: "The central epic of the Ulster Cycle, recounting the cattle raid of Cooley " \
                             "and the hero Cú Chulainn's single-handed defence of Ulster. " \
                             "Composed in Old and Middle Irish, preserved in the Book of Leinster (12th c.).",
      translation_abbreviation: "DUN", translation_name: "Joseph Dunn (1914)",
      progress: cb
    ).run
    when "tain_irish" then Import::Celtic.new(
      file: source("celtic/tain_yellow_book.txt"),
      scripture_name: "Táin Bó Cúailnge",
      scripture_slug: "tain-bo-cuailnge",
      scripture_description: "The central epic of the Ulster Cycle, recounting the cattle raid of Cooley " \
                             "and the hero Cú Chulainn's single-handed defence of Ulster. " \
                             "Composed in Old and Middle Irish, preserved in the Book of Leinster (12th c.).",
      translation_abbreviation: "SOK", translation_name: "Strachan & O'Keeffe, Yellow Book of Lecan (1912)",
      translation_language: "Old Irish", edition_type: "original",
      progress: cb
    ).run
    # Lebor Gabála Érenn — Old/Middle Irish text from Macalister critical edition
    when "lebor_gabala" then Import::LeborGabala.new(
      files: (1..5).map { |n| source("celtic/lebor_gabala_#{n}.txt") },
      progress: cb
    ).run
    # Norse texts — Poetic Edda and Prose Edda
    when "poetic_edda" then Import::Norse.new(
      file: source("norse/poetic_edda_bellows.txt"),
      format: :poetic,
      scripture_name: "Poetic Edda",
      scripture_slug: "poetic-edda",
      scripture_description: "A collection of Old Norse poems from the medieval Codex Regius manuscript (c. 1270). " \
                             "Contains mythological lays about the Norse gods and heroic lays about legendary figures. " \
                             "The primary source for Norse mythology and cosmology.",
      translation_abbreviation: "BEL",
      translation_name: "Henry Adams Bellows (1923)",
      progress: cb
    ).run
    when "poetic_edda_old_norse" then Import::Norse.new(
      directory: source("norse/poetic_edda_old_norse"),
      format: :poetic,
      scripture_name: "Poetic Edda",
      scripture_slug: "poetic-edda",
      scripture_description: "A collection of Old Norse poems from the medieval Codex Regius manuscript (c. 1270). " \
                             "Contains mythological lays about the Norse gods and heroic lays about legendary figures. " \
                             "The primary source for Norse mythology and cosmology.",
      translation_abbreviation: "GJE",
      translation_name: "Guðni Jónsson Edition (Old Norse)",
      translation_language: "Old Norse",
      edition_type: "original",
      progress: cb
    ).run
    when "prose_edda" then Import::Norse.new(
      file: source("norse/prose_edda_brodeur.txt"),
      format: :prose,
      scripture_name: "Prose Edda",
      scripture_slug: "prose-edda",
      scripture_description: "Written by Snorri Sturluson c. 1220, a manual of poetics that preserves " \
                             "Norse mythological narratives. Contains the Gylfaginning (cosmogony and mythology), " \
                             "Skáldskaparmál (poetic diction), and Háttatal (verse forms).",
      translation_abbreviation: "BRO",
      translation_name: "Arthur Gilchrist Brodeur (1916)",
      progress: cb
    ).run
    when "prose_edda_old_norse" then Import::Norse.new(
      directory: source("norse/prose_edda_old_norse"),
      format: :prose,
      scripture_name: "Prose Edda",
      scripture_slug: "prose-edda",
      scripture_description: "Written by Snorri Sturluson c. 1220, a manual of poetics that preserves " \
                             "Norse mythological narratives. Contains the Gylfaginning (cosmogony and mythology), " \
                             "Skáldskaparmál (poetic diction), and Háttatal (verse forms).",
      translation_abbreviation: "GJS",
      translation_name: "Guðni Jónsson Edition (Old Norse)",
      translation_language: "Old Norse",
      edition_type: "original",
      progress: cb
    ).run
    # Classify translations by edition type (critical, devotional, original)
    when "classify_translations" then classify_translations
    else raise ArgumentError, "Unknown importer: #{key}"
    end
  end

  def source(path)
    Rails.root.join("db/seeds/sources", path)
  end

  def progress_callback
    lambda do |processed, total|
      @import_run&.update_columns(processed_count: processed, total_count: total)
      raise CancelledError, "Import cancelled" if @import_run&.reload&.cancelled?
    end
  end

  def run_tafsir(cb)
    Import::Tafsir::EDITIONS.each_key do |edition|
      edition_dir = source("tafsir/#{edition}")
      Import::Tafsir.new(directory: edition_dir, edition: edition, progress: cb).run if edition_dir.exist?
    end
  end

  def run_suttacentral(cb)
    Import::Suttacentral.new(
      pali_dir: source("suttacentral/dhp/pali"),
      translation_dir: source("suttacentral/dhp/en"),
      translation_abbreviation: "SUJ",
      translation_name: "Bhikkhu Sujato",
      scripture_name: "Dhammapada",
      scripture_slug: "dhammapada",
      progress: cb
    ).run
  end

  def run_hadith(cb)
    files = source("hadith").glob("*.json").sort
    files.each_with_index do |file, idx|
      cb.call(idx, files.size)
      Import::Hadith.new(file: file).run
    end
    cb.call(files.size, files.size)
  end

  # Import all available source data
  def run_all
    %w[
      bible_kjv bible_asv bible_ylt bible_darby
      quran_arabic quran_sahih quran_yusufali quran_pickthall tafsir
      sblgnt suttacentral hadith sira dead_sea_scrolls
      gilgamesh enuma_elish
      mabinogion mabinogion_welsh tain tain_irish lebor_gabala
      poetic_edda_old_norse poetic_edda prose_edda_old_norse prose_edda
      strongs_hebrew strongs_greek classify_translations
    ].each do |sub_key|
      sub_run = ImportRun.create!(key: sub_key)
      perform(sub_key, import_run: sub_run)
    end
  end

  # Classify translations by edition type (critical, devotional, original)
  def classify_translations
    classifications = {
      # Original language texts
      "WLC" => "original", "SBLGNT" => "original", "QAR" => "original", "PLI" => "original",
      "HAR" => "original",
      # Critical/scholarly editions and translations
      "LXX" => "critical", "ASV" => "critical",
      # Devotional translations
      "KJV" => "devotional", "YLT" => "devotional", "DBY" => "devotional",
      "SAH" => "devotional", "YAL" => "devotional", "PKT" => "devotional", "SUJ" => "devotional",
      "HEN" => "devotional",
      "SEN" => "devotional"
    }

    classifications.each do |abbr, type|
      Translation.where(abbreviation: abbr, edition_type: nil).update_all(edition_type: type)
    end

    # DSS scroll transcriptions are original texts
    Translation.where(edition_type: nil).joins(:corpus).where(corpora: { slug: "dead-sea-scrolls" }).update_all(edition_type: "original")
  end

  def total_record_count
    TranslationSegment.count + Commentary.count + LexiconEntry.count + OriginalLanguageToken.count
  end
end
