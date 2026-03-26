namespace :import do
  desc "Download public domain source files to db/seeds/sources/"
  task download: :environment do
    require "net/http"
    require "uri"

    sources_dir = Rails.root.join("db/seeds/sources")

    downloads = {
      "kjv.json" => "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/json/KJV.json",
      "asv.json" => "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/json/ASV.json",
      "quran_arabic.txt" => "https://tanzil.net/pub/download/index.php?quranType=simple&outType=txt-2",
      "quran_sahih.txt" => "https://tanzil.net/trans/en.sahih",
      "quran-data.xml" => "https://tanzil.net/res/text/metadata/quran-data.xml"
    }

    downloads.each do |filename, url|
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

  desc "Import all available source data"
  task all: :environment do
    Rake::Task["import:download"].invoke

    sources = Rails.root.join("db/seeds/sources")

    if sources.join("kjv.json").exist?
      Import::BibleJson.new(
        file: sources.join("kjv.json"),
        abbreviation: "KJV",
        name: "King James Version",
        language: "English"
      ).run
    end

    if sources.join("asv.json").exist?
      Import::BibleJson.new(
        file: sources.join("asv.json"),
        abbreviation: "ASV",
        name: "American Standard Version",
        language: "English"
      ).run
    end

    if sources.join("quran_arabic.txt").exist?
      Import::QuranTanzil.new(
        file: sources.join("quran_arabic.txt"),
        abbreviation: "QAR",
        name: "Quran (Simple Arabic)",
        language: "Arabic"
      ).run
    end

    if sources.join("quran_sahih.txt").exist?
      Import::QuranTanzil.new(
        file: sources.join("quran_sahih.txt"),
        abbreviation: "SAH",
        name: "Sahih International",
        language: "English"
      ).run
    end
  end
end
