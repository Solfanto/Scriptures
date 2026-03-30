# Downloads public domain source files to db/seeds/sources/.
# Can be run from admin UI (async) or via rake import:download (sync).
class DownloadSourcesJob < ApplicationJob
  queue_as :default

  def perform
    require "net/http"
    require "uri"

    sources_dir = Rails.root.join("db/seeds/sources")
    sources_dir.mkpath

    # scrollmapper/bible_databases — MIT licence
    # Bible translations are public domain (pre-1923)
    downloads = {
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
    download_files(sources_dir, downloads.merge(hadith_downloads))

    # morphgnt/sblgnt — SBLGNT text: SBLGNT EULA; morphological annotations: CC BY-SA 3.0
    sblgnt_dir = sources_dir.join("sblgnt")
    sblgnt_dir.mkpath
    sblgnt_books = %w[61-Mt 62-Mk 63-Lk 64-Jn 65-Ac 66-Ro 67-1Co 68-2Co 69-Ga 70-Eph 71-Php 72-Col 73-1Th 74-2Th 75-1Ti 76-2Ti 77-Tit 78-Phm 79-Heb 80-Jas 81-1Pe 82-2Pe 83-1Jn 84-2Jn 85-3Jn 86-Jud 87-Re]
    sblgnt_downloads = sblgnt_books.to_h { |book| [ "sblgnt/#{book}.txt", "https://raw.githubusercontent.com/morphgnt/sblgnt/master/#{book}-morphgnt.txt" ] }
    download_files(sources_dir, sblgnt_downloads)

    # suttacentral/bilara-data — Pali root text: public domain; Sujato translation: CC0 1.0
    dhp_files = %w[dhp1-20 dhp21-32 dhp33-43 dhp44-59 dhp60-75 dhp76-89 dhp90-99 dhp100-115 dhp116-128 dhp129-145 dhp146-156 dhp157-166 dhp167-178 dhp179-196 dhp197-208 dhp209-220 dhp221-234 dhp235-255 dhp256-272 dhp273-289 dhp290-305 dhp306-319 dhp320-333 dhp334-359 dhp360-382 dhp383-423]
    { "pali" => "root/pli/ms/sutta/kn/dhp/%s_root-pli-ms.json",
      "en" => "translation/en/sujato/sutta/kn/dhp/%s_translation-en-sujato.json" }.each do |lang_dir, url_pattern|
      dir = sources_dir.join("suttacentral/dhp/#{lang_dir}")
      dir.mkpath
      sc_downloads = dhp_files.to_h { |f| [ "suttacentral/dhp/#{lang_dir}/#{f}.json", "https://raw.githubusercontent.com/suttacentral/bilara-data/published/#{format(url_pattern, f)}" ] }
      download_files(sources_dir, sc_downloads)
    end

    # spa5k/tafsir_api — Quranic exegesis (tafsir) commentary data
    # Classical tafsir texts are public domain; dataset is open source
    tafsir_base = "https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir"
    %w[en-tafisr-ibn-kathir en-al-jalalayn ar-tafsir-al-tabari].each do |edition|
      dir = sources_dir.join("tafsir/#{edition}")
      dir.mkpath
      tafsir_downloads = (1..114).to_h { |surah| [ "tafsir/#{edition}/#{surah}.json", "#{tafsir_base}/#{edition}/#{surah}.json" ] }
      download_files(sources_dir, tafsir_downloads)
    end
  end

  private

  def download_files(base_dir, files)
    files.each do |filename, url|
      path = base_dir.join(filename)
      next if path.exist? && path.size > 100

      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      File.write(path, response.body) if response.is_a?(Net::HTTPSuccess)
    end
  end
end
