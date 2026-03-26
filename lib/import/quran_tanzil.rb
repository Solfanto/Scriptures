require "rexml/document"

module Import
  class QuranTanzil
    # Surah metadata: index => { name:, tname:, ename:, type:, ayas: }
    # Loaded from quran-data.xml if available, otherwise uses English names.

    def initialize(file:, abbreviation:, name:, language:)
      @file = file
      @abbreviation = abbreviation
      @name = name
      @language = language
    end

    def run
      lines = File.readlines(@file, chomp: true).reject { |l| l.strip.empty? || l.start_with?("#") }

      puts "Importing #{@abbreviation} (#{@name}) — #{lines.size} verses"

      ensure_tradition_and_corpus
      translation = ensure_translation
      load_surah_metadata

      total = 0
      current_surah = nil
      current_division = nil

      lines.each do |line|
        surah_num, ayah_num, text = line.split("|", 3)
        surah_num = surah_num.to_i
        ayah_num = ayah_num.to_i

        if current_surah != surah_num
          current_surah = surah_num
          meta = @surah_metadata[surah_num] || {}

          scripture = Scripture.find_or_create_by!(corpus: @quran_corpus, slug: surah_slug(surah_num, meta)) do |s|
            s.name = meta[:ename] || "Surah #{surah_num}"
            s.position = surah_num
            s.description = [
              meta[:tname] ? "#{meta[:tname]} (#{meta[:name]})" : nil,
              meta[:type] ? "#{meta[:type]} surah" : nil
            ].compact.join(". ")
          end

          current_division = Division.find_or_create_by!(scripture: scripture, number: 1) do |d|
            d.name = meta[:ename] || "Surah #{surah_num}"
            d.position = 1
          end
        end

        passage = Passage.find_or_create_by!(division: current_division, number: ayah_num) do |p|
          p.position = ayah_num
        end

        PassageTranslation.find_or_create_by!(passage: passage, translation: translation) do |pt|
          pt.text = text.strip
        end

        total += 1
      end

      puts "  #{@abbreviation}: #{total} passage translations imported"
    end

    private

    def ensure_tradition_and_corpus
      islamic = Tradition.find_or_create_by!(slug: "islamic") do |t|
        t.name = "Islamic"
      end

      @quran_corpus = Corpus.find_or_create_by!(slug: "quran") do |c|
        c.name = "Quran"
        c.tradition = islamic
        c.description = "The central religious text of Islam."
      end
    end

    def ensure_translation
      Translation.find_or_create_by!(abbreviation: @abbreviation, corpus: @quran_corpus) do |t|
        t.name = @name
        t.language = @language
      end
    end

    def load_surah_metadata
      @surah_metadata = {}
      metadata_file = @file.dirname.join("quran-data.xml")

      return unless metadata_file.exist?

      doc = REXML::Document.new(File.read(metadata_file))
      doc.elements.each("quran/suras/sura") do |el|
        index = el.attributes["index"].to_i
        @surah_metadata[index] = {
          name: el.attributes["name"],
          tname: el.attributes["tname"],
          ename: el.attributes["ename"],
          type: el.attributes["type"],
          ayas: el.attributes["ayas"].to_i
        }
      end
    end

    def surah_slug(num, meta)
      if meta[:ename]
        meta[:ename].downcase.gsub(/\s+/, "-").gsub(/[^a-z0-9\-]/, "")
      else
        "surah-#{num}"
      end
    end
  end
end
