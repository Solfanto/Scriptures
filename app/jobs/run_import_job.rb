class RunImportJob < ApplicationJob
  queue_as :default

  def perform(key)
    case key
    when "all"           then run_all
    # Bible translations from scrollmapper JSON format
    when "bible_kjv"     then Import::BibleJson.new(file: source("kjv.json"), abbreviation: "KJV", name: "King James Version", language: "English").run
    when "bible_asv"     then Import::BibleJson.new(file: source("asv.json"), abbreviation: "ASV", name: "American Standard Version", language: "English").run
    when "bible_ylt"     then Import::BibleJson.new(file: source("ylt.json"), abbreviation: "YLT", name: "Young's Literal Translation", language: "English").run
    when "bible_darby"   then Import::BibleJson.new(file: source("darby.json"), abbreviation: "DBY", name: "Darby Translation", language: "English").run
    # Quran from Tanzil pipe-delimited text format
    when "quran_arabic"  then Import::QuranTanzil.new(file: source("quran_arabic.txt"), abbreviation: "QAR", name: "Quran (Simple Arabic)", language: "Arabic").run
    when "quran_sahih"   then Import::QuranTanzil.new(file: source("quran_sahih.txt"), abbreviation: "SAH", name: "Sahih International", language: "English").run
    when "quran_yusufali" then Import::QuranTanzil.new(file: source("quran_yusufali.txt"), abbreviation: "YAL", name: "Yusuf Ali", language: "English").run
    when "quran_pickthall" then Import::QuranTanzil.new(file: source("quran_pickthall.txt"), abbreviation: "PKT", name: "Pickthall", language: "English").run
    # Tafsir (Quranic exegesis) from spa5k/tafsir_api JSON files
    when "tafsir"        then run_tafsir
    # SBLGNT Greek New Testament from MorphGNT word-level files
    when "sblgnt"        then Import::Sblgnt.new(directory: source("sblgnt")).run
    # SuttaCentral bilara-data (Pali + English)
    when "suttacentral"  then run_suttacentral
    # Hadith collections from AhmedBaset/hadith-json by_book JSON format
    when "hadith"        then run_hadith
    # Dead Sea Scrolls from BiblicalDSS JSON
    when "dead_sea_scrolls" then Import::DeadSeaScrolls.new(file: source("biblical_dss.json")).run
    # Strong's lexicon from OpenScriptures JS format
    when "strongs_hebrew" then Import::StrongsLexicon.new(file: source("strongs_hebrew.js"), language: "Hebrew").run
    when "strongs_greek" then Import::StrongsLexicon.new(file: source("strongs_greek.js"), language: "Greek").run
    # Classify translations by edition type (critical, devotional, original)
    when "classify_translations" then classify_translations
    else raise ArgumentError, "Unknown importer: #{key}"
    end
  end

  private

  def source(path)
    Rails.root.join("db/seeds/sources", path)
  end

  def run_tafsir
    Import::Tafsir::EDITIONS.each_key do |edition|
      edition_dir = source("tafsir/#{edition}")
      Import::Tafsir.new(directory: edition_dir, edition: edition).run if edition_dir.exist?
    end
  end

  def run_suttacentral
    Import::Suttacentral.new(
      pali_dir: source("suttacentral/dhp/pali"),
      translation_dir: source("suttacentral/dhp/en"),
      translation_abbreviation: "SUJ",
      translation_name: "Bhikkhu Sujato",
      scripture_name: "Dhammapada",
      scripture_slug: "dhammapada"
    ).run
  end

  def run_hadith
    source("hadith").glob("*.json").sort.each do |file|
      Import::Hadith.new(file: file).run
    end
  end

  # Import all available source data
  def run_all
    %w[
      bible_kjv bible_asv bible_ylt bible_darby
      quran_arabic quran_sahih quran_yusufali quran_pickthall tafsir
      sblgnt suttacentral hadith dead_sea_scrolls
      strongs_hebrew strongs_greek classify_translations
    ].each { |key| perform(key) }
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
      "HEN" => "devotional"
    }

    classifications.each do |abbr, type|
      Translation.where(abbreviation: abbr, edition_type: nil).update_all(edition_type: type)
    end

    # DSS scroll transcriptions are original texts
    Translation.where(edition_type: nil).joins(:corpus).where(corpora: { slug: "dead-sea-scrolls" }).update_all(edition_type: "original")
  end
end
