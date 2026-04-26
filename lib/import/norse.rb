module Import
  class Norse
    # Imports Norse mythological texts from Project Gutenberg, Internet Archive,
    # or CLTK/heimskringla.no plain text files.
    #
    # Supports:
    #   - Poetic Edda — Bellows English (1923) / Old Norse (Guðni Jónsson)
    #   - Prose Edda — Brodeur English (1916) / Old Norse (Guðni Jónsson)
    #
    # Mapping:
    #   Tradition "Norse" → Corpus "Norse Mythology" → Scripture
    #   → Division (one per poem/section) → Passage (one per stanza/paragraph)
    #   → TranslationSegment

    GUTENBERG_START = /\*{3}\s*START OF/i
    GUTENBERG_END = /\*{3}\s*END OF/i

    SKIP_HEADINGS = %w[
      INTRODUCTION GENERAL INTRODUCTORY NOTES CONTENTS
      BIBLIOGRAPHY INDEX PRONUNCIATION APPENDIX PREFACE
      GLOSSARY CORRIGENDA LIST PRINTED PUBLISHED LAYS
      PRONOUNCING EDITORS TRANSLATOR
    ].freeze

    # Canonical ordering of Poetic Edda poems.
    # Fixed positions ensure Old Norse and English translations share divisions.
    POETIC_EDDA_POEMS = [
      # Lays of the Gods
      { position: 1,  name: "Völuspá" },
      { position: 2,  name: "Hávamál" },
      { position: 3,  name: "Vafþrúðnismál" },
      { position: 4,  name: "Grímnismál" },
      { position: 5,  name: "Skírnismál" },
      { position: 6,  name: "Hárbarðsljóð" },
      { position: 7,  name: "Hymiskviða" },
      { position: 8,  name: "Lokasenna" },
      { position: 9,  name: "Þrymskviða" },
      { position: 10, name: "Völundarkviða" },
      { position: 11, name: "Alvíssmál" },
      # Additional mythological poems
      { position: 12, name: "Baldrs Draumar" },
      { position: 13, name: "Rígsþula" },
      { position: 14, name: "Hyndluljóð" },
      { position: 15, name: "Svipdagsmál" },
      { position: 16, name: "Gróttasöngr" },
      # Lays of the Heroes
      { position: 17, name: "Helgakviða Hundingsbana I" },
      { position: 18, name: "Helgakviða Hjörvarðssonar" },
      { position: 19, name: "Helgakviða Hundingsbana II" },
      { position: 20, name: "Frá Dauða Sinfjötla" },
      { position: 21, name: "Grípisspá" },
      { position: 22, name: "Reginsmál" },
      { position: 23, name: "Fáfnismál" },
      { position: 24, name: "Sigrdrífumál" },
      { position: 25, name: "Brot af Sigurðarkviðu" },
      { position: 26, name: "Guðrúnarkviða I" },
      { position: 27, name: "Sigurðarkviða in Skamma" },
      { position: 28, name: "Helreið Brynhildar" },
      { position: 29, name: "Dráp Niflunga" },
      { position: 30, name: "Guðrúnarkviða II" },
      { position: 31, name: "Guðrúnarkviða III" },
      { position: 32, name: "Oddrúnargrátr" },
      { position: 33, name: "Atlakviða" },
      { position: 34, name: "Atlamál in Grænlenzku" },
      { position: 35, name: "Guðrúnarhvöt" },
      { position: 36, name: "Hamðismál" }
    ].freeze

    # Map Bellows anglicized headings → canonical poem names
    BELLOWS_HEADINGS = {
      "VOLUSPO" => "Völuspá",
      "HOVAMOL" => "Hávamál",
      "VAFTHRUTHNISMOL" => "Vafþrúðnismál",
      "GRIMNISMOL" => "Grímnismál",
      "SKIRNISMOL" => "Skírnismál",
      "HARBARTHSLJOTH" => "Hárbarðsljóð",
      "HYMISKVITHA" => "Hymiskviða",
      "LOKASENNA" => "Lokasenna",
      "THRYMSKVITHA" => "Þrymskviða",
      "VOLUNDARKVITHA" => "Völundarkviða",
      "ALVISSMOL" => "Alvíssmál",
      "BALDRS DRAUMAR" => "Baldrs Draumar",
      "RIGSTHULA" => "Rígsþula",
      "HYNDLULJOTH" => "Hyndluljóð",
      "SVIPDAGSMOL" => "Svipdagsmál",
      "HELGAKVITHA HUNDINGSBANA I" => "Helgakviða Hundingsbana I",
      "HELGAKVITHA HJORVARTHSSONAR" => "Helgakviða Hjörvarðssonar",
      "HELGAKVITHA HUNDINGSBANA II" => "Helgakviða Hundingsbana II",
      "FRA DAUTHA SINFJOTLA" => "Frá Dauða Sinfjötla",
      "GRIPISSPO" => "Grípisspá",
      "REGINSMOL" => "Reginsmál",
      "FAFNISMOL" => "Fáfnismál",
      "SIGRDRIFUMOL" => "Sigrdrífumál",
      "BROT AF SIGURTHARKVITHU" => "Brot af Sigurðarkviðu",
      "GUTHRUNARKVITHA I" => "Guðrúnarkviða I",
      "SIGURTHARKVITHA EN SKAMMA" => "Sigurðarkviða in Skamma",
      "HELREITH BRYNHILDAR" => "Helreið Brynhildar",
      "DRAP NIFLUNGA" => "Dráp Niflunga",
      "GUTHRUNARKVITHA II" => "Guðrúnarkviða II",
      "GUTHRUNARKVITHA III" => "Guðrúnarkviða III",
      "ODDRUNARGRATR" => "Oddrúnargrátr",
      "ATLAKVITHA" => "Atlakviða",
      "ATLAMOL EN GRÖNLENZKU" => "Atlamál in Grænlenzku",
      "GUTHRUNARHVOT" => "Guðrúnarhvöt",
      "HAMTHESMOL" => "Hamðismál"
    }.freeze

    # Map CLTK local filenames (without extension) → canonical poem names
    CLTK_POEM_FILES = {
      "voluspa" => "Völuspá",
      "havamal" => "Hávamál",
      "vafthrudnismal" => "Vafþrúðnismál",
      "grimnismal" => "Grímnismál",
      "skirnismal" => "Skírnismál",
      "harbardsljod" => "Hárbarðsljóð",
      "hymiskvida" => "Hymiskviða",
      "lokasenna" => "Lokasenna",
      "thrymskvida" => "Þrymskviða",
      "volundarkvida" => "Völundarkviða",
      "alvissmal" => "Alvíssmál",
      "baldrs_draumar" => "Baldrs Draumar",
      "rigsthula" => "Rígsþula",
      "hyndluljod" => "Hyndluljóð",
      "grottasongr" => "Gróttasöngr",
      "fafnismal" => "Fáfnismál",
      "sigrdrifumal" => "Sigrdrífumál",
      "gudrunarkvida" => "Guðrúnarkviða I",
      "helreid_brynhildar" => "Helreið Brynhildar",
      "drap_niflunga" => "Dráp Niflunga",
      "oddrunarkvida" => "Oddrúnargrátr",
      "atlakvida" => "Atlakviða",
      "atlamal" => "Atlamál in Grænlenzku",
      "gudrunarhvot" => "Guðrúnarhvöt",
      "hamthismal" => "Hamðismál"
    }.freeze

    # Prose Edda sections with CLTK filenames
    PROSE_EDDA_SECTIONS = [
      { position: 1, name: "Prologue",       cltk: "prologus" },
      { position: 2, name: "Gylfaginning",   cltk: "gylfaginning" },
      { position: 3, name: "Skáldskaparmál", cltk: "skaaldskaparmaal" },
      { position: 4, name: "Háttatal",       cltk: "haattatal" }
    ].freeze

    def initialize(file: nil, directory: nil, format: :poetic,
                   scripture_name:, scripture_slug:, scripture_description:,
                   translation_abbreviation:, translation_name:,
                   translation_language: "English", edition_type: "critical",
                   corpus_name: "Norse Mythology", corpus_slug: "norse-mythology",
                   corpus_description: nil, progress: nil)
      @file = file ? Pathname.new(file) : nil
      @directory = directory ? Pathname.new(directory) : nil
      @format = format
      @scripture_name = scripture_name
      @scripture_slug = scripture_slug
      @scripture_description = scripture_description
      @translation_abbreviation = translation_abbreviation
      @translation_name = translation_name
      @translation_language = translation_language
      @edition_type = edition_type
      @corpus_name = corpus_name
      @corpus_slug = corpus_slug
      @corpus_description = corpus_description
      @progress = progress
    end

    def run
      ensure_tradition_and_corpus

      scripture = Scripture.find_or_create_by!(corpus: @corpus, slug: @scripture_slug) do |s|
        s.name = @scripture_name
        s.position = Scripture.where(corpus: @corpus).count + 1
        s.description = @scripture_description
      end

      translation = ensure_translation

      divisions = if @directory
        @format == :poetic ? parse_old_norse_poems : parse_old_norse_prose
      else
        raw = File.read(@file, encoding: "UTF-8")
        raw.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")
        @format == :poetic ? parse_poetic_edda_bellows(raw) : parse_prose_edda(raw)
      end

      total = divisions.sum { |d| d[:passages].size }
      done = 0
      @progress&.call(0, total)

      divisions.each do |div_data|
        division = Division.find_or_create_by!(scripture: scripture, number: div_data[:position]) do |d|
          d.name = div_data[:name]
          d.position = div_data[:position]
        end

        div_data[:passages].each_with_index do |text, idx|
          passage_number = idx + 1
          passage = Passage.find_or_create_by!(division: division, number: passage_number) do |p|
            p.position = passage_number
          end

          TranslationSegment.find_or_create_for_range(
            translation: translation, start_passage: passage, end_passage: passage, text: text
          )

          done += 1
          @progress&.call(done, total) if done % 50 == 0
        end
      end

      @progress&.call(total, total)
      puts "  #{@scripture_name}: #{done} passages across #{divisions.size} divisions"
    end

    private

    def poem_position(name)
      POETIC_EDDA_POEMS.find { |p| p[:name] == name }&.fetch(:position)
    end

    # --- Poetic Edda Bellows (single Gutenberg file) ---

    def parse_poetic_edda_bellows(raw)
      text = strip_gutenberg_wrapper(raw)
      lines = text.lines.map(&:rstrip)

      # Find poem section boundaries using known headings
      boundaries = []
      lines.each_with_index do |line, idx|
        stripped = line.strip
        next if stripped.empty?
        next unless BELLOWS_HEADINGS.key?(stripped)
        boundaries << { heading: stripped, start: idx }
      end

      max_pos = POETIC_EDDA_POEMS.last[:position]
      next_pos = max_pos + 1

      poems = boundaries.each_with_index.filter_map do |boundary, idx|
        end_line = idx + 1 < boundaries.size ? boundaries[idx + 1][:start] : lines.size
        section_lines = lines[(boundary[:start] + 1)...end_line]

        stanzas = extract_bellows_stanzas(section_lines)
        next if stanzas.empty?

        canonical = BELLOWS_HEADINGS[boundary[:heading]]
        pos = poem_position(canonical)
        unless pos
          pos = next_pos
          next_pos += 1
        end

        { position: pos, name: canonical, passages: stanzas }
      end

      poems.sort_by { |p| p[:position] }
    end

    def extract_bellows_stanzas(lines)
      stanzas = []
      current = nil
      in_notes = false
      in_intro = false

      lines.each do |line|
        stripped = line.strip

        if stripped == "INTRODUCTORY NOTE"
          stanzas << current if current
          current = nil
          in_intro = true
          next
        end

        next if in_notes

        if stripped =~ /\ANOTES?\z/ || stripped =~ /\ANOTES ON /i
          stanzas << current if current
          current = nil
          in_notes = true
          next
        end

        # New numbered stanza
        if stripped =~ /\A(\d+)\.\s+(.*)/
          stanzas << current if current
          current = $2.strip
          in_intro = false
        elsif !in_intro && current && stripped.present?
          next if stripped =~ /\A\d+\z/         # page numbers
          next if stripped =~ /\A[ivxlcdm]+\z/i # roman page numbers
          current = "#{current}\n#{stripped}"
        elsif current && stripped.empty?
          stanzas << current
          current = nil
        end
      end

      stanzas << current if current
      stanzas.map { |s| clean_verse(s) }.reject { |s| s.length < 10 }
    end

    # --- Old Norse Poetic Edda (CLTK multi-file) ---

    def parse_old_norse_poems
      poems = @directory.glob("*.txt").filter_map do |file|
        poem_key = file.basename(".txt").to_s
        canonical = CLTK_POEM_FILES[poem_key]
        next unless canonical

        pos = poem_position(canonical)
        next unless pos

        text = File.read(file, encoding: "UTF-8")
        text.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")

        stanzas = parse_old_norse_stanzas(text)
        next if stanzas.empty?

        { position: pos, name: canonical, passages: stanzas }
      end

      poems.sort_by { |p| p[:position] }
    end

    def parse_old_norse_stanzas(text)
      lines = text.lines.map(&:rstrip)
      stanzas = []
      current_lines = []
      in_stanza = false

      lines.each do |line|
        stripped = line.strip

        if stripped =~ /\A(\d+)\.\z/
          # Stanza number on its own line — start new stanza
          stanzas << current_lines.join("\n") if current_lines.any?
          current_lines = []
          in_stanza = true
        elsif in_stanza && stripped.empty?
          stanzas << current_lines.join("\n") if current_lines.any?
          current_lines = []
          in_stanza = false
        elsif in_stanza && stripped.present?
          current_lines << stripped
        end
      end

      stanzas << current_lines.join("\n") if current_lines.any?
      stanzas.reject { |s| s.strip.length < 5 }
    end

    # --- Prose Edda (DjVu or Gutenberg text) ---

    def parse_prose_edda(raw)
      text = clean_djvu_text(strip_gutenberg_wrapper(raw))
      lines = text.lines.map(&:rstrip)

      sections = []
      current_section = nil
      current_paragraph = nil

      lines.each do |line|
        stripped = line.strip

        if prose_section_heading?(stripped)
          flush_paragraph(current_section, current_paragraph)
          current_paragraph = nil
          sections << current_section if current_section && current_section[:paragraphs].any?

          section_info = PROSE_EDDA_SECTIONS.find { |s| stripped.upcase.include?(s[:name].upcase) }
          pos = section_info ? section_info[:position] : (sections.size + 1)
          name = section_info ? section_info[:name] : titleize(stripped)

          current_section = { position: pos, name: name, paragraphs: [] }
        elsif current_section
          if stripped.empty?
            flush_paragraph(current_section, current_paragraph)
            current_paragraph = nil
          elsif current_paragraph
            current_paragraph = "#{current_paragraph} #{stripped}"
          else
            current_paragraph = stripped
          end
        end
      end

      flush_paragraph(current_section, current_paragraph)
      sections << current_section if current_section && current_section[:paragraphs].any?

      sections
        .reject { |s| s[:paragraphs].empty? }
        .map do |s|
          {
            position: s[:position],
            name: s[:name],
            passages: s[:paragraphs].map { |p| clean_text(p) }.reject { |p| p.length < 30 }
          }
        end
    end

    def prose_section_heading?(line)
      return false if line.empty? || line.length > 50
      up = line.upcase
      %w[PROLOGUE GYLFAGINNING SKALDSKAPARMAL SKÁLDSKAPARMÁL HÁTTATAL HATTATAL].any? { |h| up.include?(h) }
    end

    # --- Old Norse Prose Edda (CLTK multi-file) ---

    def parse_old_norse_prose
      PROSE_EDDA_SECTIONS.filter_map do |section_info|
        file = @directory.join("#{section_info[:cltk]}.txt")
        next unless file.exist?

        text = File.read(file, encoding: "UTF-8")
        text.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")

        paragraphs = parse_prose_paragraphs(text)
        next if paragraphs.empty?

        { position: section_info[:position], name: section_info[:name], passages: paragraphs }
      end
    end

    def parse_prose_paragraphs(text)
      paragraphs = []
      current = nil

      text.each_line do |line|
        stripped = line.rstrip.strip

        if stripped.empty?
          if current
            paragraphs << clean_text(current)
            current = nil
          end
        elsif current
          current = "#{current} #{stripped}"
        else
          current = stripped
        end
      end

      paragraphs << clean_text(current) if current
      paragraphs.reject { |p| p.length < 20 }
    end

    # --- Shared helpers ---

    def strip_gutenberg_wrapper(raw)
      lines = raw.lines
      start_idx = lines.index { |l| l.match?(GUTENBERG_START) }
      end_idx = lines.rindex { |l| l.match?(GUTENBERG_END) }

      if start_idx && end_idx
        lines[(start_idx + 1)...end_idx].join
      elsif start_idx
        lines[(start_idx + 1)..].join
      else
        raw
      end
    end

    def clean_djvu_text(raw)
      raw
        .gsub(/  +/, " ")            # DjVu double-spacing artifact
        .gsub(/(\w)- (\w)/, '\1\2')  # Hyphenated line breaks
    end

    def flush_paragraph(section, paragraph)
      section[:paragraphs] << paragraph if section && paragraph
    end

    def skip_heading?(line)
      normalized = line.upcase.gsub(/[^A-Z\s]/, "").strip
      SKIP_HEADINGS.any? { |skip| normalized.start_with?(skip) }
    end

    def titleize(text)
      small_words = %w[of the and in to a an on for at by with en]
      text.strip.split.map.with_index { |w, i|
        if i > 0 && small_words.include?(w.downcase)
          w.downcase
        else
          w.capitalize
        end
      }.join(" ")
    end

    def clean_text(text)
      text
        .gsub(/\s+/, " ")
        .gsub(/[''ʼ]/, "'")
        .gsub(/["""]/, '"')
        .strip
    end

    def clean_verse(text)
      text
        .lines
        .map { |l| l.gsub(/\s+/, " ").gsub(/[''ʼ]/, "'").gsub(/["""]/, '"').strip }
        .reject(&:empty?)
        .join("\n")
    end

    def ensure_tradition_and_corpus
      tradition = Tradition.find_or_create_by!(slug: "norse") do |t|
        t.name = "Norse"
        t.description = "Old Norse religious and mythological texts including the Poetic Edda, " \
                        "Prose Edda, and skaldic poetry."
      end

      @corpus = Corpus.find_or_create_by!(slug: @corpus_slug) do |c|
        c.name = @corpus_name
        c.tradition = tradition
        c.description = @corpus_description || "The Poetic Edda and Prose Edda, foundational texts " \
                        "of Old Norse mythology and cosmology."
      end
    end

    def ensure_translation
      Translation.find_or_create_by!(abbreviation: @translation_abbreviation, corpus: @corpus) do |t|
        t.name = @translation_name
        t.language = @translation_language
        t.edition_type = @edition_type
      end
    end
  end
end
