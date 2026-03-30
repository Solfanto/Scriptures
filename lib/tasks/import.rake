namespace :import do
  desc "Download public domain source files to db/seeds/sources/"
  task download: :environment do
    require "net/http"
    require "uri"

    sources_dir = Rails.root.join("db/seeds/sources")

    downloads = {
      # scrollmapper/bible_databases — MIT licence
      # Bible translations are public domain (pre-1923)
      "kjv.json" => "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/json/KJV.json",
      "asv.json" => "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/json/ASV.json",
      "ylt.json" => "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/json/YLT.json",
      "darby.json" => "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/json/Darby.json",

      # Tanzil.net — CC BY 3.0 (attribution required: "Tanzil.net")
      # Quran text is not copyrightable; translations vary by translator
      "quran_arabic.txt" => "https://tanzil.net/pub/download/index.php?quranType=simple&outType=txt-2",
      "quran_sahih.txt" => "https://tanzil.net/trans/en.sahih",
      "quran_yusufali.txt" => "https://tanzil.net/trans/en.yusufali",
      "quran_pickthall.txt" => "https://tanzil.net/trans/en.pickthall",
      "quran-data.xml" => "https://tanzil.net/res/text/metadata/quran-data.xml",

      # openscriptures/strongs — CC BY-SA 3.0
      # Original Strong's dictionary (1890/1894) is public domain
      "strongs_hebrew.js" => "https://raw.githubusercontent.com/openscriptures/strongs/master/hebrew/strongs-hebrew-dictionary.js",
      "strongs_greek.js" => "https://raw.githubusercontent.com/openscriptures/strongs/master/greek/strongs-greek-dictionary.js",

      # brando130/BiblicalDSS — CC BY-NC 4.0 (non-commercial, attribution required)
      # Biblical Dead Sea Scrolls transcriptions derived from ETCBC/dss
      "biblical_dss.json" => "https://raw.githubusercontent.com/brando130/BiblicalDSS/main/biblical_dss_unicode.json"
    }

    # AhmedBaset/hadith-json — open source hadith collections
    # Hadiths are public domain religious texts; dataset is open source
    hadith_base = "https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book"
    hadith_downloads = {
      # The nine major books (Kutub al-Sittah + 3)
      "hadith/bukhari.json" => "#{hadith_base}/the_9_books/bukhari.json",
      "hadith/muslim.json" => "#{hadith_base}/the_9_books/muslim.json",
      "hadith/abudawud.json" => "#{hadith_base}/the_9_books/abudawud.json",
      "hadith/tirmidhi.json" => "#{hadith_base}/the_9_books/tirmidhi.json",
      "hadith/nasai.json" => "#{hadith_base}/the_9_books/nasai.json",
      "hadith/ibnmajah.json" => "#{hadith_base}/the_9_books/ibnmajah.json",
      "hadith/malik.json" => "#{hadith_base}/the_9_books/malik.json",
      "hadith/ahmed.json" => "#{hadith_base}/the_9_books/ahmed.json",
      "hadith/darimi.json" => "#{hadith_base}/the_9_books/darimi.json",
      # Forty hadith collections
      "hadith/nawawi40.json" => "#{hadith_base}/forties/nawawi40.json",
      "hadith/qudsi40.json" => "#{hadith_base}/forties/qudsi40.json",
      "hadith/shahwaliullah40.json" => "#{hadith_base}/forties/shahwaliullah40.json",
      # Other books
      "hadith/aladab_almufrad.json" => "#{hadith_base}/other_books/aladab_almufrad.json",
      "hadith/bulugh_almaram.json" => "#{hadith_base}/other_books/bulugh_almaram.json",
      "hadith/mishkat_almasabih.json" => "#{hadith_base}/other_books/mishkat_almasabih.json",
      "hadith/riyad_assalihin.json" => "#{hadith_base}/other_books/riyad_assalihin.json",
      "hadith/shamail_muhammadiyah.json" => "#{hadith_base}/other_books/shamail_muhammadiyah.json"
    }

    sources_dir.join("hadith").mkpath
    downloads.merge(hadith_downloads).each do |filename, url|
      path = sources_dir.join(filename)
      if path.exist? && path.size > 100
        puts "  skip  #{filename} (already exists, #{path.size} bytes)"
        next
      end

      print "  fetch #{filename}..."
      uri = URI(url)
      response = Net::HTTP.get_response(uri)

      if response.is_a?(Net::HTTPSuccess)
        File.write(path, response.body)
        puts " #{path.size} bytes"
      else
        puts " FAILED (#{response.code})"
      end
    end

    # morphgnt/sblgnt — SBLGNT text: SBLGNT EULA; morphological annotations: CC BY-SA 3.0
    sblgnt_dir = sources_dir.join("sblgnt")
    sblgnt_dir.mkpath
    sblgnt_books = %w[61-Mt 62-Mk 63-Lk 64-Jn 65-Ac 66-Ro 67-1Co 68-2Co 69-Ga 70-Eph 71-Php 72-Col 73-1Th 74-2Th 75-1Ti 76-2Ti 77-Tit 78-Phm 79-Heb 80-Jas 81-1Pe 82-2Pe 83-1Jn 84-2Jn 85-3Jn 86-Jud 87-Re]
    sblgnt_books.each do |book|
      path = sblgnt_dir.join("#{book}.txt")
      next if path.exist? && path.size > 100

      print "  fetch sblgnt/#{book}.txt..."
      uri = URI("https://raw.githubusercontent.com/morphgnt/sblgnt/master/#{book}-morphgnt.txt")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        File.write(path, response.body)
        puts " #{path.size} bytes"
      else
        puts " FAILED (#{response.code})"
      end
    end

    # suttacentral/bilara-data — Pali root text: public domain; Sujato translation: CC0 1.0
    dhp_files = %w[dhp1-20 dhp21-32 dhp33-43 dhp44-59 dhp60-75 dhp76-89 dhp90-99 dhp100-115 dhp116-128 dhp129-145 dhp146-156 dhp157-166 dhp167-178 dhp179-196 dhp197-208 dhp209-220 dhp221-234 dhp235-255 dhp256-272 dhp273-289 dhp290-305 dhp306-319 dhp320-333 dhp334-359 dhp360-382 dhp383-423]
    { "pali" => "root/pli/ms/sutta/kn/dhp/%s_root-pli-ms.json",
      "en" => "translation/en/sujato/sutta/kn/dhp/%s_translation-en-sujato.json" }.each do |lang_dir, url_pattern|
      dir = sources_dir.join("suttacentral/dhp/#{lang_dir}")
      dir.mkpath
      dhp_files.each do |f|
        path = dir.join("#{f}.json")
        next if path.exist? && path.size > 100

        print "  fetch suttacentral/dhp/#{lang_dir}/#{f}.json..."
        uri = URI("https://raw.githubusercontent.com/suttacentral/bilara-data/published/#{format(url_pattern, f)}")
        response = Net::HTTP.get_response(uri)
        if response.is_a?(Net::HTTPSuccess)
          File.write(path, response.body)
          puts " #{path.size} bytes"
        else
          puts " FAILED (#{response.code})"
        end
      end
    end
  end

  desc "Import a Bible translation from scrollmapper JSON format"
  task :bible_json, [ :file, :abbreviation, :name, :language ] => :environment do |_t, args|
    file = args[:file] || raise("Usage: rake import:bible_json[file,abbreviation,name,language]")
    abbreviation = args[:abbreviation] || raise("abbreviation required")
    name = args[:name] || abbreviation
    language = args[:language] || "English"

    importer = Import::BibleJson.new(
      file: Rails.root.join(file),
      abbreviation: abbreviation,
      name: name,
      language: language
    )
    importer.run
  end

  desc "Import Quran from Tanzil pipe-delimited text format"
  task :quran_tanzil, [ :file, :abbreviation, :name, :language ] => :environment do |_t, args|
    file = args[:file] || raise("Usage: rake import:quran_tanzil[file,abbreviation,name,language]")
    abbreviation = args[:abbreviation] || raise("abbreviation required")
    name = args[:name] || abbreviation
    language = args[:language] || "Arabic"

    importer = Import::QuranTanzil.new(
      file: Rails.root.join(file),
      abbreviation: abbreviation,
      name: name,
      language: language
    )
    importer.run
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

  desc "Import a hadith collection from AhmedBaset/hadith-json by_book JSON format"
  task :hadith, [ :file ] => :environment do |_t, args|
    file = args[:file] || raise("Usage: rake import:hadith[file]")
    Import::Hadith.new(file: Rails.root.join(file)).run
  end

  desc "Import all available source data"
  task all: :environment do
    Rake::Task["import:download"].invoke

    sources = Rails.root.join("db/seeds/sources")

    # Bible translations
    {
      "kjv.json" => [ "KJV", "King James Version", "English" ],
      "asv.json" => [ "ASV", "American Standard Version", "English" ],
      "ylt.json" => [ "YLT", "Young's Literal Translation", "English" ],
      "darby.json" => [ "DBY", "Darby Translation", "English" ]
    }.each do |file, (abbr, name, lang)|
      path = sources.join(file)
      Import::BibleJson.new(file: path, abbreviation: abbr, name: name, language: lang).run if path.exist?
    end

    # Quran translations
    {
      "quran_arabic.txt" => [ "QAR", "Quran (Simple Arabic)", "Arabic" ],
      "quran_sahih.txt" => [ "SAH", "Sahih International", "English" ],
      "quran_yusufali.txt" => [ "YAL", "Yusuf Ali", "English" ],
      "quran_pickthall.txt" => [ "PKT", "Pickthall", "English" ]
    }.each do |file, (abbr, name, lang)|
      path = sources.join(file)
      Import::QuranTanzil.new(file: path, abbreviation: abbr, name: name, language: lang).run if path.exist?
    end

    # SBLGNT Greek New Testament
    sblgnt_dir = sources.join("sblgnt")
    Import::Sblgnt.new(directory: sblgnt_dir).run if sblgnt_dir.exist? && sblgnt_dir.children.any?

    # Pali Canon — Dhammapada
    dhp_pali = sources.join("suttacentral/dhp/pali")
    dhp_en = sources.join("suttacentral/dhp/en")
    if dhp_pali.exist? && dhp_pali.children.any?
      Import::Suttacentral.new(
        pali_dir: dhp_pali,
        translation_dir: dhp_en.exist? ? dhp_en : nil,
        translation_abbreviation: "SUJ",
        translation_name: "Bhikkhu Sujato",
        scripture_name: "Dhammapada",
        scripture_slug: "dhammapada"
      ).run
    end

    # Hadith collections
    hadith_dir = sources.join("hadith")
    if hadith_dir.exist?
      hadith_dir.glob("*.json").sort.each do |file|
        Import::Hadith.new(file: file).run
      end
    end

    # Dead Sea Scrolls
    dss_file = sources.join("biblical_dss.json")
    Import::DeadSeaScrolls.new(file: dss_file).run if dss_file.exist?

    # Strong's lexicons
    Import::StrongsLexicon.new(file: sources.join("strongs_hebrew.js"), language: "Hebrew").run if sources.join("strongs_hebrew.js").exist?
    Import::StrongsLexicon.new(file: sources.join("strongs_greek.js"), language: "Greek").run if sources.join("strongs_greek.js").exist?
  end

  desc "Classify translations by edition type (critical, devotional, original)"
  task classify_translations: :environment do
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

    updated = 0
    classifications.each do |abbr, type|
      count = Translation.where(abbreviation: abbr, edition_type: nil).update_all(edition_type: type)
      updated += count
    end

    # DSS scroll transcriptions are original texts
    Translation.where(edition_type: nil).joins(:corpus).where(corpora: { slug: "dead-sea-scrolls" }).update_all(edition_type: "original")

    puts "Classified #{updated} translations"
  end
end
