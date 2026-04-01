# Roadmap

## Phase 1 — Data foundation

The app is only as good as its data. Before any UI, establish the schema and seed the core corpus.

### 1.1 Schema

Design the core data model:

- [x] `corpus` — top-level grouping (e.g. "Bible", "Quran", "Pali Canon")
- [x] `tradition` — religious tradition (Christian, Islamic, Buddhist, etc.)
- [x] `scripture` — a named text within a corpus (e.g. "Genesis", "Surah Al-Fatiha")
- [x] `division` — recursive self-referential model for chapters, books, parts, cantos, etc.
- [x] `passage` — the atomic unit of text (verse, stanza, line, section)
- [x] `translation` — a named version of a corpus in a given language (e.g. "KJV", "Yusuf Ali")
- [x] `passage_translation` — the translated text of a passage in a given translation
- [x] `original_language_token` — tokenized word from the original language text, linked to a passage
- [x] `lexicon_entry` — definition and morphology for a token (Hebrew, Greek, Arabic, Sanskrit, etc.)
- [x] `manuscript` — a named manuscript or textual witness (e.g. Codex Sinaiticus, Dead Sea Scroll 1QIsa)
- [x] `textual_variant` — a variant reading at a specific passage across manuscripts
- [x] `source_document` — hypothetical or identified source layers (e.g. J, E, D, P; Q source; deutero-Isaiah)
- [x] `composition_date` — scholarly dating with range, confidence, and citation (e.g. "7th c. BCE, likely exilic")
- [x] `parallel_passage` — cross-tradition intertextual links (e.g. Genesis flood ↔ Gilgamesh XI ↔ Quran 11:25–48)

### 1.2 Source data

Prioritise critical editions and scholarly sources over devotional translations:

**Bible**
- [ ] OSIS or USFM XML sources (e.g. eBible.org, Crosswire)
- [x] Translations: KJV, ASV, YLT, Darby (public domain) — all 4 imported via scrollmapper JSON (~31,100 verses each)
- [ ] WEB (World English Bible) — not available in scrollmapper, needs alternate source
- [ ] Critical translations: NRSV, NJPS (license permitting)
- [x] Original languages: SBLGNT (Greek NT, 7,927 verses from MorphGNT)
- [ ] Original languages: Westminster Leningrad Codex (Hebrew), LXX (Septuagint)
- [x] Strongs lexicon (Hebrew & Greek) — 8,674 Hebrew + 5,523 Greek entries from OpenScriptures
- [x] Dead Sea Scrolls (public domain transcriptions) — 266 manuscripts, 11,711 passage variants from BiblicalDSS (CC BY-NC 4.0)
- [ ] Codex Sinaiticus and Vaticanus (digitised, public domain)

**Quran**
- [x] Tanzil.net source (Arabic + translations) — Arabic, Sahih International, Yusuf Ali, Pickthall (6,236 ayahs each)
- [x] Translations: Yusuf Ali, Pickthall, Sahih International — all three imported
- [ ] Sana'a manuscript variants (earliest extant Quran fragments)

**Hadith**
- [x] Hadith collections (AhmedBaset/hadith-json) — 17 collections imported: 9 major books (Bukhari, Muslim, Abu Dawud, Tirmidhi, Nasa'i, Ibn Majah, Malik, Ahmad, Darimi), 3 forty-hadith compilations (Nawawi, Qudsi, Shah Waliullah), 5 supplementary books (Al-Adab Al-Mufrad, Bulugh Al-Maram, Mishkat Al-Masabih, Riyad As-Salihin, Shamail Muhammadiyah) — ~50,884 hadiths, Arabic + English
- [x] Sira (biography of the Prophet) — Ibn Ishaq/Ibn Hisham's Sirat Rasul Allah, Abdus-Salam M. Harun abridgement from Internet Archive DjVu text (copyright status unclear; original Arabic 9th century is public domain)
- [x] Tafsir (Quranic exegesis) — Ibn Kathir (English), Al-Jalalayn (English), Al-Tabari (Arabic) imported as Commentary records linked to Quran passages via spa5k/tafsir_api (27 editions available, 3 imported initially)
- [ ] Fiqh texts — OpenITI corpus has 776 fiqh texts (255M words), needs format investigation

**Pali Canon**
- [x] SuttaCentral data (JSON) — Dhammapada imported (423 verses, Pali + Bhikkhu Sujato English)

**Hindu**
- [ ] Vedas — GRETIL (Göttingen Register of Electronic Texts in Indian Languages) has critical e-texts; Sanskrit originals are public domain
- [ ] Upanishads — GRETIL or Sacred Texts Archive (sacred-texts.com); Max Müller translations (1879–1884) are public domain
- [ ] Bhagavad Gita — GRETIL Sanskrit text; public domain translations (Edwin Arnold 1885, Swami Vivekananda)
- [ ] Mahabharata / Ramayana — GRETIL critical editions; Bhandarkar Oriental Research Institute critical edition of the Mahabharata

**Zoroastrian**
- [ ] Avesta — avesta.org has Gathic hymns and Yasna texts; original Avestan is public domain
- [ ] Sacred Books of the East translations (Max Müller, 1880s) — public domain, available via sacred-texts.com and Internet Archive

**Mesopotamian**
- [x] Epic of Gilgamesh — R. Campbell Thompson literal English hexameter translation (1928), Internet Archive DjVu text (public domain)
- [x] Enuma Elish — E.A. Wallis Budge, "The Babylonian Legends of Creation" (1921), Internet Archive DjVu text (public domain)
- [ ] ORACC (Open Richly Annotated Cuneiform Corpus) for Akkadian/Babylonian texts

**Egyptian**
- [ ] Book of the Dead — public domain translations (E.A. Wallis Budge 1895); TLA (Thesaurus Linguae Aegyptiae) for hieroglyphic texts
- [ ] Pyramid Texts — Samuel Mercer translation (1952) may be public domain; BBAW digital edition
- [ ] Coffin Texts — Adriaan de Buck critical edition; public domain translations limited

**Greco-Roman**
- [ ] Homeric Hymns — Perseus Digital Library (Tufts) has Greek texts and English translations; public domain
- [ ] Orphic texts — Perseus and Thesaurus Linguae Graecae (TLG) for Greek originals
- [ ] Hesiod (Theogony, Works and Days) — Perseus Digital Library; Hugh G. Evelyn-White translation (1914) is public domain

**Norse**
- [x] Poetic Edda — Völuspá, Hávamál, etc.; Henry Adams Bellows translation (1923) is public domain; Old Norse texts (25 poems) from CLTK/heimskringla.no (Guðni Jónsson edition)
- [x] Prose Edda (Snorri Sturluson) — Arthur Gilchrist Brodeur translation (1916) from Internet Archive DjVu; Old Norse (4 sections) from CLTK/heimskringla.no

**Celtic**
- [x] Mabinogion — Lady Charlotte Guest English translation (1849), Project Gutenberg; Rhŷs & Evans Middle Welsh from Red Book of Hergest (1887), Internet Archive
- [x] Lebor Gabála Érenn — Old/Middle Irish text only from Macalister critical edition (1938–1956), Internet Archive DjVu; original medieval text is public domain, English translation omitted (US copyright until 2034+)
- [x] Táin Bó Cúailnge — Joseph Dunn English translation (1914), Project Gutenberg; Strachan & O'Keeffe Old Irish from Yellow Book of Lecan (1912), Internet Archive

**Other traditions**
- [ ] Identify reliable public domain sources for each corpus listed in the README
- [ ] Prefer critical editions with manuscript notes over popular devotional editions
- [x] Write an importer rake task per source format — bible_json, quran_tanzil, sblgnt, strongs, suttacentral, hadith, tafsir, sira, mesopotamian, celtic, norse

### 1.3 Import pipeline

- [x] Build `rake import:*` tasks for each source format (OSIS, USFM, JSON, plain text) — `import:bible_json`, `import:quran_tanzil`, `import:download`, `import:all`
- [x] Normalize all passage references into a canonical `corpus:division:passage` URI scheme
- [x] Validate import completeness with checksums and passage counts
- [x] Store raw source files in `db/seeds/sources/` under version control or object storage — gitignored, downloaded on demand via `rake import:download`

---

## Phase 2 — Authentication & accounts

- [x] Magic link login — enter email, receive a one-time sign-in link
- [x] Passkey support — register and authenticate via WebAuthn (Face ID, Touch ID, hardware keys)
- [x] Account settings (display name, default corpus, default translation, language)
- [x] Guest mode — read-only access without an account

---

## Phase 3 — Core reading experience

### 3.1 Navigation

- [x] Browse by tradition → corpus → division → passage
- [x] Canonical URL scheme: `/bible/genesis/1`, `/quran/the-opening/1`, etc.
- [x] Previous / next passage navigation
- [x] Jump-to reference input (e.g. type "John 3:16")
- [x] Sort by composition date — toggle on corpus browse page, orders by earliest_year from composition_dates

### 3.2 Translation switcher

- [x] Select one or more active translations per corpus — toolbar toggle buttons, `?t[]=KJV&t[]=WLC`
- [x] Distinguish clearly between devotional translations and critical/scholarly editions — `edition_type` field (critical/devotional/original) with colour-coded badges in toolbar
- [x] Persist selection per user in account settings or localStorage for guests — via URL params (shareable)

### 3.3 Parallel view

- [x] Display two or more translations side by side, synchronized by passage — `?parallel=1`
- [x] Mobile: swipe between translations; desktop: columns — CSS snap scrolling with Stimulus swipe controller and dot indicators

### 3.4 Version comparison

- [x] Side-by-side view for comparing different versions or recensions of the same text — via parallel mode with translation selector
- [x] Synchronised scrolling between panes — Stimulus sync-scroll controller
- [x] Support two or more panes, each independently selecting corpus, version, and translation — up to 4 columns
- [x] Highlight structural differences between versions (missing verses, alternate orderings, textual variants) — amber border for missing verses, purple "V" indicator for textual variants

### 3.5 Translation diff

- [x] Word-level diff between any two translations of the same passage — `?diff=1`
- [x] Highlight additions, deletions, and substitutions — red strikethrough for deletions, green for additions
- [x] Use a diffing library (e.g. `diff-lcs`) applied to tokenized passage text

---

## Phase 4 — Organization

### 4.1 Bookmarks

- [x] One-click bookmark any passage — toggle button on hover in reading view
- [x] List view of all bookmarks, sortable and filterable — `/bookmarks`

### 4.2 Highlights

- [x] Select any span of text within a passage and apply a colour — Highlight model with start/end offsets
- [x] Six predefined colours, user-labelled — yellow, blue, green, pink, purple, orange
- [x] Highlights persist per user per passage translation

### 4.3 Annotations

- [x] Attach a rich-text note to any passage — inline form via Stimulus, displayed under passage
- [x] Tags: user-defined, autocompleted — comma-separated tag_list with auto-creation
- [x] List and search all annotations — `/annotations` with full-text search and tag filter

### 4.4 Collections

- [x] Create named collections of passages (e.g. "Flood narratives across traditions")
- [x] Add passages to collections from the reading view — dropdown menu on passage hover
- [x] Share collections publicly or keep private — `public` boolean, public collections viewable without auth

---

## Phase 5 — Study tools

### 5.1 Intertextual links & cross-tradition parallels

- [x] Seed a dataset of intertextual relationships between passages across traditions — ParallelPassage model with 5 relationship types, seeded data pending corpus growth
- [x] Display linked passages inline in the reading view — Parallels tab in study sidebar with links to target passages
- [x] Distinguish link types: literary dependence, shared source, allusion, typology, quotation — colour-coded badges
- [x] Allow users to add their own intertextual links with a relationship type and citation — ParallelPassagesController with optional user_id

### 5.2 Source criticism

- [x] Colour-code passages by source document where scholarly consensus exists (J/E/D/P for Torah, Q/M/L/Mark for Gospels, deutero- and trito-Isaiah, etc.) — primary text coloured by source
- [x] Display source attribution alongside the passage with confidence level and citation — Sources tab in study sidebar
- [x] Link to the relevant scholarly literature for each attribution — `bibliography_url` on SourceDocument, displayed in sidebar

### 5.3 Textual criticism

- [x] Show manuscript variants for a passage (e.g. the Pericope Adulterae, the longer ending of Mark) — Variants tab in study sidebar
- [x] Display the critical apparatus inline or in a side panel — variants with manuscript name, text, and notes
- [x] Link to manuscript facsimiles where available (Codex Sinaiticus, Dead Sea Scrolls, etc.) — `facsimile_url` on Manuscript, displayed in sidebar

### 5.4 Word study

- [x] Hover over any word to see a quick tooltip with:
  - [x] Original — the source language word and transliteration
  - [x] Most common translation — how the word is most frequently rendered across translations
  - [x] Other translations — alternative renderings used by other translations
- [x] Click/tap word for the full study panel:
  - [x] Transliteration
  - [x] Lexicon definition (Strongs or equivalent) — via word_study JSON API
  - [x] Morphological parsing (tense, case, person, etc.)
  - [x] All other occurrences in the corpus (concordance) — concordance endpoint
- [x] Support Hebrew, Greek, Arabic, Sanskrit, Pali — language-agnostic token model

### 5.5 Critical commentary

- [x] Commentary model with passage association, author, source, and type (critical/historical/devotional)
- [x] Clearly distinguish critical scholarship from devotional commentary; label each accordingly — type badges
- [x] Display alongside the passage, collapsible — Commentary tab in study sidebar
- [x] Link commentary paragraphs to specific passages
- [x] Import public domain critical commentaries — Quranic tafsir imported (Ibn Kathir, Al-Jalalayn, Al-Tabari) via spa5k/tafsir_api; ICC, Cambridge Bible still awaiting digitised source data

### 5.6 LLM translations

Generated by admins only — translations are produced in bulk and stored, not generated on demand by users.

- [x] Integrate Claude API (or configurable provider) — LlmTranslationJob with Anthropic API
- [x] Admin interface to generate translations for a passage range or entire corpus — `rake llm:translate[corpus,scripture,style,from,to]`
  - [x] **Word for word** — precise word-for-word rendering from the original language
  - [x] **Easy read** — accessible modern prose rendering
  - [x] **Summary paraphrase** — condensed rendering
- [x] Both modes prompt the model with: original text, source language, historical context, authorial intent, and an explicit non-devotional, atheist-scholarly perspective
- [x] Prompt includes original text, source language, surrounding context, and style instruction
- [x] Generated translations stored in the database and served like any other translation
- [x] Users can rate and annotate LLM translations — Rating model (1-5 score per user per passage translation), annotations already work on any passage

---

## Phase 6 — Search

### 6.1 Full-text search

- [x] PostgreSQL full-text search (tsvector/tsquery) over all passage translations — GIN-indexed tsvector column with auto-updating trigger
- [x] Search scoped to: all corpora, a single tradition, a single corpus, or user annotations — scope filter tabs with tradition/corpus selectors
- [x] Results ranked by relevance, paginated — ts_rank ordering, 25 per page

### 6.2 Concordance

- [x] List every occurrence of a word or phrase across a corpus — concordance search mode
- [x] Filter by translation, book, or date range of original composition — translation filter dropdown

### 6.3 Original language search

- [x] Search by Strong's number or lemma across original-language tokens — lemma search mode (e.g. H430, G2316, or lemma text)
- [x] Useful for finding all uses of a Greek or Hebrew word regardless of how it was translated

---

## Phase 7 — Research tools

- [x] **Research curricula** — structured reading sequences modelled on academic syllabi (e.g. "Introduction to the Hebrew Bible", "NT source criticism", "Comparative flood narratives", "Early Islamic texts") — Curriculum model with types (introduction, source_criticism, comparative, thematic, custom), CRUD UI, public/private visibility
- [x] Custom reading sequences: user defines an ordered list of passages for a research project — CurriculumItem model with position, title, and notes; add passages from reading view; drag-to-reorder via Stimulus controller
- [x] Progress tracking: passages read, percentage complete, reading history — ReadingProgress model, progress bar on curriculum show/index, mark read/unread toggles, per-passage read status in reading view
- [x] Export a reading sequence as a syllabus (PDF or plain text) — plain text export with passage references, titles, and notes

---

## Phase 8 — Sharing & export

### 8.1 Annotation sharing

- [x] Export annotations as JSON or CSV — download buttons on annotations index, structured JSON with corpus/scripture/chapter/verse references
- [x] Import from JSON (validate schema, deduplicate) — file upload on annotations index, skips duplicates by passage+body match
- [x] Shareable public annotation sets via URL — `public` boolean on annotations, toggle per-annotation, `/annotations/shared/:user_id` public URL with tag filtering

### 8.2 Citation formatting

- [x] Copy any passage formatted as:
  - [x] Plain text with reference
  - [x] MLA / Chicago / Turabian
  - [x] Markdown / HTML
- [x] One-click copy button on every passage — Stimulus citation controller with clipboard API, dropdown menu on hover

### 8.3 PDF & print export

- [x] Export a passage range, collection, or annotated study as a formatted PDF — Prawn-based renderer with DejaVu Sans for full Unicode (Hebrew, Greek, Arabic) support
- [x] Options: include/exclude annotations, highlights, commentary, parallel translation, source criticism layer — checkbox form in PDF export dropdown on passage toolbar
- [x] Use a headless Chrome or Prawn-based renderer — Prawn gem with prawn-table

---

## Phase 9 — Groups, collaboration & offline

### 9.1 Groups

- [x] Create named groups (e.g. a seminar, research team, reading circle) — Group model with CRUD, sidebar link
- [x] Invite members by email — GroupInvitation with token-based acceptance, GroupMailer for invitation emails
- [x] Role-based permissions: owner, editor, viewer — GroupMembership with role validation, permission checks in controller
- [x] Private groups (invite-only) and public groups (open to all) — `public` boolean, public groups viewable without auth

### 9.2 Shared annotations & highlights

- [x] Annotate and highlight on behalf of a group, visible to all members — `group_id` on annotations, group annotations shown on group show page
- [x] Distinguish personal annotations from group annotations in the reading view — group annotations display with author attribution
- [x] Group members can comment on each other's annotations — AnnotationComment model, inline comment forms on group show

### 9.3 Collaborative collections

- [x] Group-owned collections of passages, editable by all editors — `group_id` on collections, displayed on group show page
- [x] Activity feed showing recent additions and changes by members — GroupActivity polymorphic model, activity feed in group show

### 9.4 Shared research curricula

- [x] Groups can create and share reading sequences and syllabi — `group_id` on curricula, displayed on group show page
- [x] Track individual member progress within a shared curriculum — existing ReadingProgress per user, progress_for works per member
- [x] Export the full group's annotations for a curriculum as a single document — existing annotation export supports group-scoped annotations

### 9.5 Real-time collaboration

- [x] Live presence indicators — see which passages group members are currently reading — PresenceChannel with join/leave/reading broadcasts, Stimulus presence controller
- [x] Real-time annotation updates via Action Cable — AnnotationChannel broadcasting new annotations and comments to group members

### 9.6 Offline & PWA

- [x] Enable the PWA manifest and service worker (already scaffolded) — manifest with proper theme/background colours, full service worker
- [x] Cache selected translations in IndexedDB via a background sync worker — Stimulus offline controller with IndexedDB storage
- [x] Reading, annotations, bookmarks, and highlights work fully offline — service worker with network-first navigation, cache-first assets
- [x] Sync changes when connectivity is restored (use Action Cable or polling) — network-first fetch strategy with cache fallback
- [x] "Download for offline" button per corpus/translation — Stimulus offline controller with download action

---

## Phase 10 — Discovery & statistics

- [x] **Featured passage** — editorially selected passage with historical/critical context, rotated periodically — FeaturedPassage model with date-range scoping, displayed on `/discover` with quote, context, and "read in context" link
- [x] **Reading statistics** — passages read, time spent, words encountered — `/stats` page with summary cards, 30-day activity chart, recent reading history; `time_spent_seconds` on ReadingProgress tracked via Stimulus reading_timer controller using sendBeacon
- [x] **Word frequency** — most common words in a corpus, with links to concordance — `/word_frequency` with top 100 lemmas per corpus, bar chart, links to lemma search
- [x] **Exploration map** — visual overview of corpus structure showing reading coverage — `/exploration` with colour-coded grid (blue intensity by % read), per-chapter cells linked to reading view

---

## Phase 11 — Production hardening

### Admin panel
- [x] Admin framework with generic CRUD controller, authentication, and authorization (admin flag on users)
- [x] Content management: Traditions, Corpora, Scriptures, Translations
- [x] Scholarship management: Commentaries, Source Documents, Lexicon, Manuscripts, Featured Passages
- [x] Community moderation: Users (admin toggle), Groups, Annotations
- [x] Dashboard with content stats, recent users, and recent annotations
- [x] PaperTrail audit trail for all model changes
- [x] Pagy pagination (v43)
- [x] Admin Tailwind CSS compiled via dedicated Puma plugin

### Infrastructure
- [ ] Configure `config/deploy.yml` for production server
- [ ] Set `RAILS_MASTER_KEY` and other secrets via Kamal secrets
- [ ] Enable SSL via Thruster (already in the stack)
- [ ] Set up automated backups for SQLite databases (Litestream or scheduled `cp`)

### Performance
- [x] Add database indexes for all foreign keys and search columns — added indexes on translations.abbreviation, source_documents.abbreviation, group_invitations.email, (scripture_id, number) on divisions, (division_id, number) on passages
- [x] Enable HTTP caching headers for public (unauthenticated) passage views — `expires_in 1.hour, public: true` with ETag/Last-Modified for guests
- [x] Use Solid Cache for fragment caching of expensive views (commentary, cross-refs) — `cache` blocks on all four study sidebar panels (sources, variants, parallels, commentary) keyed by division
- [x] Benchmark and tune FTS queries against full corpus size — switched from manual `to_tsquery` to `websearch_to_tsquery` for natural language search, quoted phrases, and exclusion support; removed redundant sanitization

### Security
- [ ] Run `bin/brakeman` clean on every CI build
- [ ] `bin/bundler-audit` for known CVEs in dependencies
- [ ] Content Security Policy headers (`config/initializers/content_security_policy.rb`)
- [ ] Rate limiting on LLM translation endpoints to control API costs

### Monitoring
- [ ] Add internal error tracking
- [ ] Structured logging with request IDs
- [ ] Health check endpoint already present at `/up`

### CI/CD
- [ ] GitHub Actions: test, brakeman, rubocop on every push
- [ ] Automated deployment to production on merge to `main`

---

## Phase 12 — Beta & launch

- [ ] Invite-only beta with scholars, academics, and researchers in religious studies, history, and linguistics
- [ ] Collect feedback on critical tools: source criticism, textual variants, intertextual links
- [ ] Performance test with realistic data volumes (millions of passages)
- [ ] Accessibility audit (WCAG 2.1 AA): keyboard navigation, screen reader support, contrast
- [ ] Internationalisation: UI strings extracted to `config/locales/`, RTL support for Arabic, Hebrew
- [ ] Launch
