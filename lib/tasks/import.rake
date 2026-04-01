namespace :import do
  desc "Download public domain source files to db/seeds/sources/"
  task download: :environment do
    DownloadSourcesJob.perform_now
  end

  desc "Import a Bible translation from scrollmapper JSON format"
  task :bible_json, [ :file, :abbreviation, :name, :language ] => :environment do |_t, args|
    file = args[:file] || raise("Usage: rake import:bible_json[file,abbreviation,name,language]")
    abbreviation = args[:abbreviation] || raise("abbreviation required")
    name = args[:name] || abbreviation
    language = args[:language] || "English"

    Import::BibleJson.new(
      file: Rails.root.join(file),
      abbreviation: abbreviation,
      name: name,
      language: language
    ).run
  end

  desc "Import Quran from Tanzil pipe-delimited text format"
  task :quran_tanzil, [ :file, :abbreviation, :name, :language ] => :environment do |_t, args|
    file = args[:file] || raise("Usage: rake import:quran_tanzil[file,abbreviation,name,language]")
    abbreviation = args[:abbreviation] || raise("abbreviation required")
    name = args[:name] || abbreviation
    language = args[:language] || "Arabic"

    Import::QuranTanzil.new(
      file: Rails.root.join(file),
      abbreviation: abbreviation,
      name: name,
      language: language
    ).run
  end

  desc "Import a SuttaCentral bilara-data text (Pali + English)"
  task :suttacentral, [ :pali_dir, :en_dir, :abbreviation, :name, :scripture_name, :scripture_slug ] => :environment do |_t, args|
    Import::Suttacentral.new(
      pali_dir: Rails.root.join(args[:pali_dir]),
      translation_dir: args[:en_dir] ? Rails.root.join(args[:en_dir]) : nil,
      translation_abbreviation: args[:abbreviation],
      translation_name: args[:name],
      scripture_name: args[:scripture_name],
      scripture_slug: args[:scripture_slug]
    ).run
  end

  desc "Import Dead Sea Scrolls from BiblicalDSS JSON"
  task :dead_sea_scrolls, [ :file ] => :environment do |_t, args|
    file = args[:file] || "db/seeds/sources/biblical_dss.json"
    Import::DeadSeaScrolls.new(file: Rails.root.join(file)).run
  end

  desc "Import SBLGNT Greek New Testament from MorphGNT word-level files"
  task :sblgnt, [ :directory ] => :environment do |_t, args|
    directory = args[:directory] || "db/seeds/sources/sblgnt"
    Import::Sblgnt.new(directory: Rails.root.join(directory)).run
  end

  desc "Import Strong's lexicon from OpenScriptures JS format"
  task :strongs, [ :file, :language ] => :environment do |_t, args|
    file = args[:file] || raise("Usage: rake import:strongs[file,language]")
    language = args[:language] || raise("language required (Hebrew or Greek)")

    Import::StrongsLexicon.new(file: Rails.root.join(file), language: language).run
  end

  desc "Import tafsir (Quranic exegesis) from spa5k/tafsir_api JSON files"
  task :tafsir, [ :directory, :edition ] => :environment do |_t, args|
    directory = args[:directory] || raise("Usage: rake import:tafsir[directory,edition]")
    edition = args[:edition] || raise("edition required (e.g. en-tafisr-ibn-kathir)")
    Import::Tafsir.new(directory: Rails.root.join(directory), edition: edition).run
  end

  desc "Import a hadith collection from AhmedBaset/hadith-json by_book JSON format"
  task :hadith, [ :file ] => :environment do |_t, args|
    file = args[:file] || raise("Usage: rake import:hadith[file]")
    Import::Hadith.new(file: Rails.root.join(file)).run
  end

  desc "Import Sira (prophetic biography) from Internet Archive DjVu text"
  task :sira, [ :file ] => :environment do |_t, args|
    file = args[:file] || "db/seeds/sources/sira/sirat_ibn_hisham.txt"
    Import::Sira.new(file: Rails.root.join(file)).run
  end

  desc "Import Epic of Gilgamesh from Thompson 1928 DjVu text"
  task :gilgamesh, [ :file ] => :environment do |_t, args|
    file = args[:file] || "db/seeds/sources/mesopotamian/gilgamesh_thompson.txt"
    RunImportJob.perform_now("gilgamesh")
  end

  desc "Import Enuma Elish from Budge 1921 DjVu text"
  task :enuma_elish, [ :file ] => :environment do |_t, args|
    file = args[:file] || "db/seeds/sources/mesopotamian/enuma_elish_budge.txt"
    RunImportJob.perform_now("enuma_elish")
  end

  desc "Import The Mabinogion from Guest 1849 Gutenberg text (English)"
  task :mabinogion, [ :file ] => :environment do |_t, args|
    file = args[:file] || "db/seeds/sources/celtic/mabinogion_guest.txt"
    RunImportJob.perform_now("mabinogion")
  end

  desc "Import The Mabinogion from Red Book of Hergest (Middle Welsh)"
  task :mabinogion_welsh, [ :file ] => :environment do |_t, args|
    file = args[:file] || "db/seeds/sources/celtic/mabinogion_red_book.txt"
    RunImportJob.perform_now("mabinogion_welsh")
  end

  desc "Import Táin Bó Cúailnge from Dunn 1914 Gutenberg text (English)"
  task :tain, [ :file ] => :environment do |_t, args|
    file = args[:file] || "db/seeds/sources/celtic/tain_dunn.txt"
    RunImportJob.perform_now("tain")
  end

  desc "Import Táin Bó Cúailnge from Yellow Book of Lecan (Old Irish)"
  task :tain_irish, [ :file ] => :environment do |_t, args|
    file = args[:file] || "db/seeds/sources/celtic/tain_yellow_book.txt"
    RunImportJob.perform_now("tain_irish")
  end

  desc "Import Lebor Gabála Érenn (Old Irish text) from Macalister critical edition"
  task lebor_gabala: :environment do
    RunImportJob.perform_now("lebor_gabala")
  end

  desc "Import Poetic Edda from Bellows 1923 Gutenberg text (English)"
  task poetic_edda: :environment do
    RunImportJob.perform_now("poetic_edda")
  end

  desc "Import Poetic Edda in Old Norse from CLTK/heimskringla.no"
  task poetic_edda_old_norse: :environment do
    RunImportJob.perform_now("poetic_edda_old_norse")
  end

  desc "Import Prose Edda from Brodeur 1916 DjVu text (English)"
  task prose_edda: :environment do
    RunImportJob.perform_now("prose_edda")
  end

  desc "Import Prose Edda in Old Norse from CLTK/heimskringla.no"
  task prose_edda_old_norse: :environment do
    RunImportJob.perform_now("prose_edda_old_norse")
  end

  desc "Import all available source data"
  task all: :environment do
    Rake::Task["import:download"].invoke
    RunImportJob.perform_now("all")
  end

  desc "Classify translations by edition type (critical, devotional, original)"
  task classify_translations: :environment do
    RunImportJob.perform_now("classify_translations")
  end
end
