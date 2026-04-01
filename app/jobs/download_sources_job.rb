# Downloads public domain source files to db/seeds/sources/.
# Supports downloading all sources or just those for a specific importer key.
class DownloadSourcesJob < ApplicationJob
  queue_as :default

  SCROLLMAPPER_BASE = "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/formats/json"
  TANZIL_BASE = "https://tanzil.net"
  HADITH_BASE = "https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book"
  SBLGNT_BOOKS = %w[61-Mt 62-Mk 63-Lk 64-Jn 65-Ac 66-Ro 67-1Co 68-2Co 69-Ga 70-Eph 71-Php 72-Col 73-1Th 74-2Th 75-1Ti 76-2Ti 77-Tit 78-Phm 79-Heb 80-Jas 81-1Pe 82-2Pe 83-1Jn 84-2Jn 85-3Jn 86-Jud 87-Re].freeze
  DHP_FILES = %w[dhp1-20 dhp21-32 dhp33-43 dhp44-59 dhp60-75 dhp76-89 dhp90-99 dhp100-115 dhp116-128 dhp129-145 dhp146-156 dhp157-166 dhp167-178 dhp179-196 dhp197-208 dhp209-220 dhp221-234 dhp235-255 dhp256-272 dhp273-289 dhp290-305 dhp306-319 dhp320-333 dhp334-359 dhp360-382 dhp383-423].freeze
  TAFSIR_EDITIONS = %w[en-tafisr-ibn-kathir en-al-jalalayn ar-tafsir-al-tabari].freeze
  TAFSIR_BASE = "https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir"
  CLTK_EDDA_BASE = "https://raw.githubusercontent.com/cltk/old_norse_texts_heimskringla/master"

  # Per-importer download registry: importer_key => { filename => url }
  # rubocop:disable Layout/LineLength
  DOWNLOAD_REGISTRY = {
    # scrollmapper/bible_databases — MIT licence; Bible translations are public domain (pre-1923)
    "bible_kjv" => { "kjv.json" => "#{SCROLLMAPPER_BASE}/KJV.json" },
    "bible_asv" => { "asv.json" => "#{SCROLLMAPPER_BASE}/ASV.json" },
    "bible_ylt" => { "ylt.json" => "#{SCROLLMAPPER_BASE}/YLT.json" },
    "bible_darby" => { "darby.json" => "#{SCROLLMAPPER_BASE}/Darby.json" },

    # Tanzil.net — CC BY 3.0; Quran text is not copyrightable; translations vary by translator
    "quran_arabic" => {
      "quran_arabic.txt" => "#{TANZIL_BASE}/pub/download/index.php?quranType=simple&outType=txt-2",
      "quran-data.xml" => "#{TANZIL_BASE}/res/text/metadata/quran-data.xml"
    },
    "quran_sahih" => {
      "quran_sahih.txt" => "#{TANZIL_BASE}/trans/en.sahih",
      "quran-data.xml" => "#{TANZIL_BASE}/res/text/metadata/quran-data.xml"
    },
    "quran_yusufali" => {
      "quran_yusufali.txt" => "#{TANZIL_BASE}/trans/en.yusufali",
      "quran-data.xml" => "#{TANZIL_BASE}/res/text/metadata/quran-data.xml"
    },
    "quran_pickthall" => {
      "quran_pickthall.txt" => "#{TANZIL_BASE}/trans/en.pickthall",
      "quran-data.xml" => "#{TANZIL_BASE}/res/text/metadata/quran-data.xml"
    },

    # spa5k/tafsir_api — classical tafsir texts are public domain; dataset is open source
    "tafsir" => TAFSIR_EDITIONS.each_with_object({}) { |edition, h|
      (1..114).each { |surah| h["tafsir/#{edition}/#{surah}.json"] = "#{TAFSIR_BASE}/#{edition}/#{surah}.json" }
    },

    # morphgnt/sblgnt — SBLGNT text: SBLGNT EULA; morphological annotations: CC BY-SA 3.0
    "sblgnt" => SBLGNT_BOOKS.to_h { |book| [ "sblgnt/#{book}.txt", "https://raw.githubusercontent.com/morphgnt/sblgnt/master/#{book}-morphgnt.txt" ] },

    # suttacentral/bilara-data — Pali root text: public domain; Sujato translation: CC0 1.0
    "suttacentral" => %w[pali en].each_with_object({}) { |lang, h|
      pattern = lang == "pali" ? "root/pli/ms/sutta/kn/dhp/%s_root-pli-ms.json" : "translation/en/sujato/sutta/kn/dhp/%s_translation-en-sujato.json"
      DHP_FILES.each { |f| h["suttacentral/dhp/#{lang}/#{f}.json"] = "https://raw.githubusercontent.com/suttacentral/bilara-data/published/#{format(pattern, f)}" }
    },

    # AhmedBaset/hadith-json — open source hadith collections; hadiths are public domain religious texts
    "hadith" => {
      "hadith/bukhari.json" => "#{HADITH_BASE}/the_9_books/bukhari.json",
      "hadith/muslim.json" => "#{HADITH_BASE}/the_9_books/muslim.json",
      "hadith/abudawud.json" => "#{HADITH_BASE}/the_9_books/abudawud.json",
      "hadith/tirmidhi.json" => "#{HADITH_BASE}/the_9_books/tirmidhi.json",
      "hadith/nasai.json" => "#{HADITH_BASE}/the_9_books/nasai.json",
      "hadith/ibnmajah.json" => "#{HADITH_BASE}/the_9_books/ibnmajah.json",
      "hadith/malik.json" => "#{HADITH_BASE}/the_9_books/malik.json",
      "hadith/ahmed.json" => "#{HADITH_BASE}/the_9_books/ahmed.json",
      "hadith/darimi.json" => "#{HADITH_BASE}/the_9_books/darimi.json",
      "hadith/nawawi40.json" => "#{HADITH_BASE}/forties/nawawi40.json",
      "hadith/qudsi40.json" => "#{HADITH_BASE}/forties/qudsi40.json",
      "hadith/shahwaliullah40.json" => "#{HADITH_BASE}/forties/shahwaliullah40.json",
      "hadith/aladab_almufrad.json" => "#{HADITH_BASE}/other_books/aladab_almufrad.json",
      "hadith/bulugh_almaram.json" => "#{HADITH_BASE}/other_books/bulugh_almaram.json",
      "hadith/mishkat_almasabih.json" => "#{HADITH_BASE}/other_books/mishkat_almasabih.json",
      "hadith/riyad_assalihin.json" => "#{HADITH_BASE}/other_books/riyad_assalihin.json",
      "hadith/shamail_muhammadiyah.json" => "#{HADITH_BASE}/other_books/shamail_muhammadiyah.json"
    },

    # Sira — Abdus-Salam M. Harun abridgement of Ibn Hisham; original Arabic (9th c.) is public domain
    "sira" => {
      "sira/sirat_ibn_hisham.txt" => "https://archive.org/download/SiratIbnHishamBiographyOfTheProphet/Sirat%20Ibn%20Hisham%20-%20Biography%20of%20the%20Prophet_djvu.txt"
    },

    # brando130/BiblicalDSS — CC BY-NC 4.0 (non-commercial, attribution required)
    "dead_sea_scrolls" => {
      "biblical_dss.json" => "https://raw.githubusercontent.com/brando130/BiblicalDSS/main/biblical_dss_unicode.json"
    },

    # openscriptures/strongs — CC BY-SA 3.0; original Strong's dictionary (1890/1894) is public domain
    "strongs_hebrew" => { "strongs_hebrew.js" => "https://raw.githubusercontent.com/openscriptures/strongs/master/hebrew/strongs-hebrew-dictionary.js" },
    "strongs_greek" => { "strongs_greek.js" => "https://raw.githubusercontent.com/openscriptures/strongs/master/greek/strongs-greek-dictionary.js" },

    # Mesopotamian texts — public domain translations from Internet Archive
    # R. Campbell Thompson, "The Epic of Gilgamish" (1928) — literal English hexameter translation
    "gilgamesh" => { "mesopotamian/gilgamesh_thompson.txt" => "https://archive.org/download/thompson-1928-gilgamesh/Thompson_1928_Gilgamesh_djvu.txt" },
    # E.A. Wallis Budge, "The Babylonian Legends of Creation" (1921) — British Museum guide with Enuma Elish translation
    "enuma_elish" => { "mesopotamian/enuma_elish_budge.txt" => "https://archive.org/download/pdfy-MfMlja9m9e6QYsfR/The%20Babylonian%20Legends%20Of%20Creation_djvu.txt" },

    # Celtic texts — public domain translations and originals
    # Lady Charlotte Guest, "The Mabinogion" (1849) — English translation, Project Gutenberg
    "mabinogion" => { "celtic/mabinogion_guest.txt" => "https://www.gutenberg.org/cache/epub/5160/pg5160.txt" },
    # Rhŷs & Evans, "The Text of the Mabinogion from the Red Book of Hergest" (1887) — Middle Welsh, Internet Archive
    "mabinogion_welsh" => { "celtic/mabinogion_red_book.txt" => "https://archive.org/download/textofmabinogion00evanuoft/textofmabinogion00evanuoft_djvu.txt" },
    # Joseph Dunn, "The Ancient Irish Epic Tale Táin Bó Cúailnge" (1914) — English translation, Project Gutenberg
    "tain" => { "celtic/tain_dunn.txt" => "https://www.gutenberg.org/cache/epub/16464/pg16464.txt" },
    # Strachan & O'Keeffe, "The Táin Bó Cúailnge from the Yellow Book of Lecan" (1912) — Old Irish, Internet Archive
    "tain_irish" => { "celtic/tain_yellow_book.txt" => "https://archive.org/download/tinbcailng00strauoft/tinbcailng00strauoft_djvu.txt" },

    # Lebor Gabála Érenn — R.A.S. Macalister critical edition (1938–1956), Irish Texts Society
    # Original Old/Middle Irish text is public domain (medieval manuscripts); Macalister's editorial
    # work is EU/Irish public domain since 2021 (life+70). University of Toronto library scans.
    "lebor_gabala" => {
      "celtic/lebor_gabala_1.txt" => "https://archive.org/download/leborgablare01macauoft/leborgablare01macauoft_djvu.txt",
      "celtic/lebor_gabala_3.txt" => "https://archive.org/download/leborgablare03macauoft/leborgablare03macauoft_djvu.txt",
      "celtic/lebor_gabala_4.txt" => "https://archive.org/download/leborgablare04macauoft/leborgablare04macauoft_djvu.txt",
      "celtic/lebor_gabala_5.txt" => "https://archive.org/download/leborgablare00macauoft/leborgablare00macauoft_djvu.txt"
    },

    # Norse texts — Poetic Edda and Prose Edda

    # Henry Adams Bellows, "The Poetic Edda" (1923) — English translation, Project Gutenberg
    "poetic_edda" => { "norse/poetic_edda_bellows.txt" => "https://www.gutenberg.org/cache/epub/73533/pg73533.txt" },

    # Poetic Edda in Old Norse — Guðni Jónsson edition via CLTK/heimskringla.no (public domain medieval texts)
    "poetic_edda_old_norse" => {
      "norse/poetic_edda_old_norse/voluspa.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/V%C3%B6lusp%C3%A1/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/havamal.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/H%C3%A1vam%C3%A1l/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/vafthrudnismal.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Vaf%C3%BEr%C3%BA%C3%B0nism%C3%A1l/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/grimnismal.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Gr%C3%ADmnism%C3%A1l/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/skirnismal.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Sk%C3%ADrnism%C3%A1l/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/harbardsljod.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/H%C3%A1rbar%C3%B0slj%C3%B3%C3%B0/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/hymiskvida.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Hymiskvi%C3%B0a/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/lokasenna.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Lokasenna/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/thrymskvida.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/%C3%9Erymskvi%C3%B0a/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/volundarkvida.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/V%C3%B6lundarkvi%C3%B0a/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/alvissmal.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Alv%C3%ADssm%C3%A1l/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/baldrs_draumar.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Baldrs%20draumar/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/rigsthula.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/R%C3%ADgs%C3%BEula/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/hyndluljod.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Hyndlulj%C3%B3%C3%B0/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/grottasongr.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Gr%C3%B3ttas%C3%B6ngr/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/fafnismal.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/F%C3%A1fnism%C3%A1l/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/sigrdrifumal.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Sigrdr%C3%ADfum%C3%A1l/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/gudrunarkvida.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Gu%C3%B0r%C3%BAnarkvi%C3%B0a/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/helreid_brynhildar.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Helrei%C3%B0%20Brynhildar/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/drap_niflunga.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Dr%C3%A1p%20Niflunga/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/oddrunarkvida.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Oddr%C3%BAnarkvi%C3%B0a/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/atlakvida.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Atlakvi%C3%B0a/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/atlamal.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Ataml%C3%A1l%20in%20gr%C3%A6nlenzku/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/gudrunarhvot.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Gu%C3%B0r%C3%BAnarhv%C3%B6t/txt_files/complete.txt",
      "norse/poetic_edda_old_norse/hamthismal.txt" => "#{CLTK_EDDA_BASE}/S%C3%A6mundar-Edda/Ham%C3%B0ism%C3%A1l/txt_files/complete.txt"
    },

    # Arthur Gilchrist Brodeur, "The Prose Edda" (1916) — English translation, Internet Archive DjVu
    "prose_edda" => { "norse/prose_edda_brodeur.txt" => "https://archive.org/download/proseedda00snor/proseedda00snor_djvu.txt" },

    # Prose Edda in Old Norse — Guðni Jónsson edition via CLTK/heimskringla.no (public domain medieval text)
    "prose_edda_old_norse" => {
      "norse/prose_edda_old_norse/prologus.txt" => "#{CLTK_EDDA_BASE}/Snorra-Edda/txt_files/prologus.txt",
      "norse/prose_edda_old_norse/gylfaginning.txt" => "#{CLTK_EDDA_BASE}/Snorra-Edda/txt_files/gylfaginning.txt",
      "norse/prose_edda_old_norse/skaaldskaparmaal.txt" => "#{CLTK_EDDA_BASE}/Snorra-Edda/txt_files/skaaldskaparmaal.txt",
      "norse/prose_edda_old_norse/haattatal.txt" => "#{CLTK_EDDA_BASE}/Snorra-Edda/txt_files/haattatal.txtl"
    }
  }.freeze
  # rubocop:enable Layout/LineLength

  # Download all sources or just those for a specific importer key.
  def perform(key = nil)
    require "net/http"
    require "uri"

    sources_dir = Rails.root.join("db/seeds/sources")
    sources_dir.mkpath

    if key.nil? || key == "all"
      DOWNLOAD_REGISTRY.each_value { |files| download_key(sources_dir, files) }
    else
      files = DOWNLOAD_REGISTRY[key]
      download_key(sources_dir, files) if files
    end
  end

  private

  def download_key(sources_dir, files)
    # Ensure subdirectories exist
    files.each_key do |filename|
      dir = sources_dir.join(filename).dirname
      dir.mkpath unless dir == sources_dir
    end

    download_files(sources_dir, files)
  end

  def download_files(base_dir, files)
    files.each do |filename, url|
      path = base_dir.join(filename)
      next if path.exist? && path.size > 100

      response = fetch_with_redirects(url)
      File.binwrite(path, response.body) if response.is_a?(Net::HTTPSuccess)
    end
  end

  def fetch_with_redirects(url, limit = 5)
    raise "Too many redirects" if limit == 0

    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPRedirection)
      fetch_with_redirects(response["location"], limit - 1)
    else
      response
    end
  end
end
