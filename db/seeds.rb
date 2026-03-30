# Traditions
jewish = Tradition.find_or_create_by!(slug: "jewish") do |t|
  t.name = "Jewish"
  t.description = "The Jewish scriptural tradition including Torah, Nevi'im, Ketuvim, Mishnah, and Talmud."
end

christian = Tradition.find_or_create_by!(slug: "christian") do |t|
  t.name = "Christian"
  t.description = "The Christian scriptural tradition including Old Testament, New Testament, and Deuterocanon."
end

islamic = Tradition.find_or_create_by!(slug: "islamic") do |t|
  t.name = "Islamic"
  t.description = "The Islamic scriptural tradition including Quran, Hadith, Sira, and Tafsir."
end

Tradition.find_or_create_by!(slug: "ancient") do |t|
  t.name = "Ancient & Historical"
  t.description = "Ancient and historical texts including Egyptian, Mesopotamian, Norse, and Mesoamerican traditions."
end

# Corpus: Bible (shared between Jewish and Christian)
bible = Corpus.find_or_create_by!(slug: "bible") do |c|
  c.name = "Bible"
  c.tradition = jewish
  c.description = "The Hebrew Bible / Old Testament, shared foundational text of Judaism and Christianity."
end

# Corpus: New Testament
nt = Corpus.find_or_create_by!(slug: "new-testament") do |c|
  c.name = "New Testament"
  c.tradition = christian
  c.description = "The Christian New Testament, 27 books composed in Koine Greek."
end

# Corpus: Quran
Corpus.find_or_create_by!(slug: "quran") do |c|
  c.name = "Quran"
  c.tradition = islamic
  c.description = "The central religious text of Islam, believed by Muslims to be a revelation from God."
end

# Corpus: Hadith
Corpus.find_or_create_by!(slug: "hadith") do |c|
  c.name = "Hadith"
  c.tradition = islamic
  c.description = "The collected sayings, actions, and approvals of the Prophet Muhammad, transmitted through chains of narrators. The six canonical collections (Kutub al-Sittah) plus supplementary compilations."
end

# Source documents for the Bible (Documentary Hypothesis)
p_source = SourceDocument.find_or_create_by!(abbreviation: "P", corpus: bible) do |s|
  s.name = "Priestly Source"
  s.color = "blue"
  s.description = "The Priestly source, one of four sources of the Torah identified by the Documentary Hypothesis. Characterized by concern with ritual, genealogy, and precise chronology."
  s.bibliography_url = "https://en.wikipedia.org/wiki/Priestly_source"
end

SourceDocument.find_or_create_by!(abbreviation: "J", corpus: bible) do |s|
  s.name = "Yahwist Source"
  s.color = "amber"
  s.description = "The Yahwist source, characterized by use of the divine name YHWH and vivid, anthropomorphic depictions of God."
  s.bibliography_url = "https://en.wikipedia.org/wiki/Jahwist"
end

# Scriptures within Bible corpus
genesis = Scripture.find_or_create_by!(slug: "genesis", corpus: bible) do |s|
  s.name = "Genesis"
  s.position = 1
  s.description = "The first book of the Torah/Pentateuch. Contains creation narratives, ancestral stories, and the Joseph cycle."
end

Scripture.find_or_create_by!(slug: "exodus", corpus: bible) do |s|
  s.name = "Exodus"
  s.position = 2
  s.description = "The second book of the Torah. Describes the Israelite exodus from Egypt, the covenant at Sinai, and the construction of the Tabernacle."
end

# Scriptures within NT
Scripture.find_or_create_by!(slug: "matthew", corpus: nt) do |s|
  s.name = "Matthew"
  s.position = 1
  s.description = "The Gospel according to Matthew, likely composed ~85 CE."
end

Scripture.find_or_create_by!(slug: "mark", corpus: nt) do |s|
  s.name = "Mark"
  s.position = 2
  s.description = "The Gospel according to Mark, the earliest canonical Gospel, likely composed ~70 CE."
end

Scripture.find_or_create_by!(slug: "luke", corpus: nt) do |s|
  s.name = "Luke"
  s.position = 3
  s.description = "The Gospel according to Luke, likely composed ~85 CE."
end

Scripture.find_or_create_by!(slug: "john", corpus: nt) do |s|
  s.name = "John"
  s.position = 4
  s.description = "The Gospel according to John, likely composed ~90-100 CE."
end

# Divisions (chapters) for Genesis
gen_ch1 = Division.find_or_create_by!(scripture: genesis, number: 1) do |d|
  d.name = "Chapter 1"
  d.position = 1
end

Division.find_or_create_by!(scripture: genesis, number: 2) do |d|
  d.name = "Chapter 2"
  d.position = 2
end

# Passages for Genesis 1:1-5
gen_passages = (1..5).map do |n|
  Passage.find_or_create_by!(division: gen_ch1, number: n) do |p|
    p.position = n
  end
end

# Translations
wlc = Translation.find_or_create_by!(abbreviation: "WLC", corpus: bible) do |t|
  t.name = "Westminster Leningrad Codex"
  t.language = "Hebrew"
  t.edition_type = "original"
  t.description = "The Masoretic Text as represented in the Westminster Leningrad Codex, the oldest complete manuscript of the Hebrew Bible."
end

kjv = Translation.find_or_create_by!(abbreviation: "KJV", corpus: bible) do |t|
  t.name = "King James Version"
  t.language = "English"
  t.edition_type = "devotional"
  t.description = "The 1611 Authorized Version, the most influential English translation. Public domain."
end

lxx = Translation.find_or_create_by!(abbreviation: "LXX", corpus: bible) do |t|
  t.name = "Septuagint"
  t.language = "Greek"
  t.edition_type = "critical"
  t.description = "The ancient Greek translation of the Hebrew scriptures, produced in Alexandria c. 3rd-2nd century BCE."
end

# Genesis 1:1-5 in Hebrew (WLC / Masoretic Text)
hebrew_texts = [
  "בְּרֵאשִׁית בָּרָא אֱלֹהִים אֵת הַשָּׁמַיִם וְאֵת הָאָרֶץ׃",
  "וְהָאָרֶץ הָיְתָה תֹהוּ וָבֹהוּ וְחֹשֶׁךְ עַל־פְּנֵי תְהוֹם וְרוּחַ אֱלֹהִים מְרַחֶפֶת עַל־פְּנֵי הַמָּיִם׃",
  "וַיֹּאמֶר אֱלֹהִים יְהִי אוֹר וַיְהִי־אוֹר׃",
  "וַיַּרְא אֱלֹהִים אֶת־הָאוֹר כִּי־טוֹב וַיַּבְדֵּל אֱלֹהִים בֵּין הָאוֹר וּבֵין הַחֹשֶׁךְ׃",
  "וַיִּקְרָא אֱלֹהִים ׀ לָאוֹר יוֹם וְלַחֹשֶׁךְ קָרָא לָיְלָה וַיְהִי־עֶרֶב וַיְהִי־בֹקֶר יוֹם אֶחָד׃"
]

# Genesis 1:1-5 in English (KJV)
kjv_texts = [
  "In the beginning God created the heaven and the earth.",
  "And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.",
  "And God said, Let there be light: and there was light.",
  "And God saw the light, that it was good: and God divided the light from the darkness.",
  "And God called the light Day, and the darkness he called Night. And the evening and the morning were the first day."
]

# Genesis 1:1-5 in Greek (Septuagint)
lxx_texts = [
  "ἐν ἀρχῇ ἐποίησεν ὁ θεὸς τὸν οὐρανὸν καὶ τὴν γῆν.",
  "ἡ δὲ γῆ ἦν ἀόρατος καὶ ἀκατασκεύαστος, καὶ σκότος ἐπάνω τῆς ἀβύσσου, καὶ πνεῦμα θεοῦ ἐπεφέρετο ἐπάνω τοῦ ὕδατος.",
  "καὶ εἶπεν ὁ θεός Γενηθήτω φῶς. καὶ ἐγένετο φῶς.",
  "καὶ εἶδεν ὁ θεὸς τὸ φῶς ὅτι καλόν. καὶ διεχώρισεν ὁ θεὸς ἀνὰ μέσον τοῦ φωτὸς καὶ ἀνὰ μέσον τοῦ σκότους.",
  "καὶ ἐκάλεσεν ὁ θεὸς τὸ φῶς ἡμέραν καὶ τὸ σκότος ἐκάλεσεν νύκτα. καὶ ἐγένετο ἑσπέρα καὶ ἐγένετο πρωί, ἡμέρα μία."
]

gen_passages.each_with_index do |passage, i|
  PassageTranslation.find_or_create_by!(passage: passage, translation: wlc) { |pt| pt.text = hebrew_texts[i] }
  PassageTranslation.find_or_create_by!(passage: passage, translation: kjv) { |pt| pt.text = kjv_texts[i] }
  PassageTranslation.find_or_create_by!(passage: passage, translation: lxx) { |pt| pt.text = lxx_texts[i] }

  # All Genesis 1:1-5 attributed to Priestly source
  PassageSourceDocument.find_or_create_by!(passage: passage, source_document: p_source)
end

# Lexicon entries for Genesis 1:1 (Hebrew)
bereshit = LexiconEntry.find_or_create_by!(strongs_number: "H7225") do |e|
  e.lemma = "רֵאשִׁית"
  e.language = "Hebrew"
  e.transliteration = "reshith"
  e.definition = "Beginning, first, chief. From rosh (head). Used to denote the start of a period or the first in rank."
  e.morphology_label = "noun, feminine, singular, construct"
end

bara = LexiconEntry.find_or_create_by!(strongs_number: "H1254") do |e|
  e.lemma = "בָּרָא"
  e.language = "Hebrew"
  e.transliteration = "bara"
  e.definition = "To create, to shape, to form. Used exclusively with God as subject in the Qal stem, indicating divine creative activity."
  e.morphology_label = "verb, Qal, perfect, 3rd person, masculine, singular"
end

elohim = LexiconEntry.find_or_create_by!(strongs_number: "H430") do |e|
  e.lemma = "אֱלֹהִים"
  e.language = "Hebrew"
  e.transliteration = "elohim"
  e.definition = "God, gods, divine beings. Plural form of eloah. When used with singular verbs, refers to the God of Israel."
  e.morphology_label = "noun, masculine, plural"
end

# Original language tokens for Genesis 1:1
gen_1_1 = gen_passages[0]
[
  { position: 1, text: "בְּרֵאשִׁית", transliteration: "bereshith", lemma: "רֵאשִׁית", morphology: "prep+n-fs-c", lexicon_entry: bereshit },
  { position: 2, text: "בָּרָא", transliteration: "bara", lemma: "בָּרָא", morphology: "v-Qp3ms", lexicon_entry: bara },
  { position: 3, text: "אֱלֹהִים", transliteration: "elohim", lemma: "אֱלֹהִים", morphology: "n-mp", lexicon_entry: elohim },
  { position: 4, text: "אֵת", transliteration: "eth", lemma: "אֵת", morphology: "part-do" },
  { position: 5, text: "הַשָּׁמַיִם", transliteration: "hashamayim", lemma: "שָׁמַיִם", morphology: "art+n-mp" },
  { position: 6, text: "וְאֵת", transliteration: "ve'eth", lemma: "וְ+אֵת", morphology: "conj+part-do" },
  { position: 7, text: "הָאָרֶץ", transliteration: "ha'arets", lemma: "אֶרֶץ", morphology: "art+n-fs" }
].each do |attrs|
  OriginalLanguageToken.find_or_create_by!(passage: gen_1_1, position: attrs[:position]) do |t|
    t.text = attrs[:text]
    t.transliteration = attrs[:transliteration]
    t.lemma = attrs[:lemma]
    t.morphology = attrs[:morphology]
    t.lexicon_entry = attrs[:lexicon_entry]
  end
end

# Manuscripts
sinaiticus = Manuscript.find_or_create_by!(abbreviation: "01", corpus: bible) do |m|
  m.name = "Codex Sinaiticus"
  m.date_description = "4th century CE"
  m.language = "Greek"
  m.description = "One of the oldest nearly complete manuscripts of the Greek Bible. Discovered at Saint Catherine's Monastery, Sinai."
  m.facsimile_url = "https://codexsinaiticus.org/en/"
end

vaticanus = Manuscript.find_or_create_by!(abbreviation: "03", corpus: bible) do |m|
  m.name = "Codex Vaticanus"
  m.date_description = "4th century CE"
  m.language = "Greek"
  m.description = "One of the oldest extant manuscripts of the Greek Bible, housed in the Vatican Library since at least the 15th century."
  m.facsimile_url = "https://digi.vatlib.it/view/MSS_Vat.gr.1209"
end

Manuscript.find_or_create_by!(abbreviation: "WLC", corpus: bible) do |m|
  m.name = "Westminster Leningrad Codex"
  m.date_description = "1008 CE"
  m.language = "Hebrew"
  m.description = "The oldest complete manuscript of the Hebrew Bible in the Masoretic Text tradition. Based on Codex Leningradensis."
end

# Textual variant example: Genesis 1:1 in Codex Sinaiticus vs Vaticanus (LXX)
TextualVariant.find_or_create_by!(passage: gen_1_1, manuscript: sinaiticus) do |v|
  v.text = "ἐν ἀρχῇ ἐποίησεν ὁ θεὸς τὸν οὐρανὸν καὶ τὴν γῆν"
  v.notes = "Sinaiticus reading of Genesis 1:1 matches the standard LXX text."
end

TextualVariant.find_or_create_by!(passage: gen_1_1, manuscript: vaticanus) do |v|
  v.text = "ἐν ἀρχῇ ἐποίησεν ὁ θεὸς τὸν οὐρανὸν καὶ τὴν γῆν"
  v.notes = "Vaticanus reading of Genesis 1:1 matches the standard LXX text. No significant variants."
end

# Composition dates
CompositionDate.find_or_create_by!(scripture: genesis) do |d|
  d.earliest_year = -950
  d.latest_year = -450
  d.confidence = "medium"
  d.description = "Composite text with earliest oral traditions (J source) possibly dating to the 10th century BCE and final redaction (P source) during or after the Babylonian exile."
  d.citation = "Friedman, R.E. (1987). Who Wrote the Bible? Harper & Row."
end

Scripture.find_by(slug: "mark", corpus: nt)&.tap do |mark|
  CompositionDate.find_or_create_by!(scripture: mark) do |d|
    d.earliest_year = 66
    d.latest_year = 74
    d.confidence = "high"
    d.description = "Widely considered the earliest canonical Gospel, composed during or shortly after the Jewish-Roman War."
    d.citation = "Marcus, J. (2000). Mark 1-8. Anchor Yale Bible Commentary."
  end
end

# Parallel passage: not yet seeded as we need passages from multiple corpora loaded via import

puts "Seeded #{Tradition.count} traditions, #{Corpus.count} corpora, #{Scripture.count} scriptures, " \
     "#{Division.count} divisions, #{Passage.count} passages, #{Translation.count} translations, " \
     "#{PassageTranslation.count} passage translations, #{SourceDocument.count} source documents, " \
     "#{LexiconEntry.count} lexicon entries, #{OriginalLanguageToken.count} tokens, " \
     "#{Manuscript.count} manuscripts, #{TextualVariant.count} textual variants, " \
     "#{CompositionDate.count} composition dates."
