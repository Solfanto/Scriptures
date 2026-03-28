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

**Pali Canon**
- [x] SuttaCentral data (JSON) — Dhammapada imported (423 verses, Pali + Bhikkhu Sujato English)

**Other traditions**
- [ ] Identify reliable public domain sources for each corpus listed in the README
- [ ] Prefer critical editions with manuscript notes over popular devotional editions
- [x] Write an importer rake task per source format — bible_json, quran_tanzil, sblgnt, strongs, suttacentral

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
- [ ] Import public domain critical commentaries (ICC, Cambridge Bible, etc.) — model ready, awaiting digitised source data

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

- [ ] Create named groups (e.g. a seminar, research team, reading circle)
- [ ] Invite members by email
- [ ] Role-based permissions: owner, editor, viewer
- [ ] Private groups (invite-only) and public groups (open to all)

### 9.2 Shared annotations & highlights

- [ ] Annotate and highlight on behalf of a group, visible to all members
- [ ] Distinguish personal annotations from group annotations in the reading view
- [ ] Group members can comment on each other's annotations

### 9.3 Collaborative collections

- [ ] Group-owned collections of passages, editable by all editors
- [ ] Activity feed showing recent additions and changes by members

### 9.4 Shared research curricula

- [ ] Groups can create and share reading sequences and syllabi
- [ ] Track individual member progress within a shared curriculum
- [ ] Export the full group's annotations for a curriculum as a single document

### 9.5 Real-time collaboration

- [ ] Live presence indicators — see which passages group members are currently reading
- [ ] Real-time annotation updates via Action Cable

### 9.6 Offline & PWA

- [ ] Enable the PWA manifest and service worker (already scaffolded)
- [ ] Cache selected translations in IndexedDB via a background sync worker
- [ ] Reading, annotations, bookmarks, and highlights work fully offline
- [ ] Sync changes when connectivity is restored (use Action Cable or polling)
- [ ] "Download for offline" button per corpus/translation

---

## Phase 10 — Discovery & statistics

- [ ] **Featured passage** — editorially selected passage with historical/critical context, rotated periodically
- [ ] **Reading statistics** — passages read, time spent, words encountered
- [ ] **Word frequency** — most common words in a corpus, with links to concordance
- [ ] **Exploration map** — visual overview of corpus structure showing reading coverage

---

## Phase 11 — Production hardening

### Infrastructure
- [ ] Configure `config/deploy.yml` for production server
- [ ] Set `RAILS_MASTER_KEY` and other secrets via Kamal secrets
- [ ] Enable SSL via Thruster (already in the stack)
- [ ] Set up automated backups for SQLite databases (Litestream or scheduled `cp`)

### Performance
- [ ] Add database indexes for all foreign keys and search columns
- [ ] Enable HTTP caching headers for public (unauthenticated) passage views
- [ ] Use Solid Cache for fragment caching of expensive views (commentary, cross-refs)
- [ ] Benchmark and tune FTS5 queries against full corpus size

### Security
- [ ] Run `bin/brakeman` clean on every CI build
- [ ] `bin/bundler-audit` for known CVEs in dependencies
- [ ] Content Security Policy headers (`config/initializers/content_security_policy.rb`)
- [ ] Rate limiting on LLM translation endpoints to control API costs

### Monitoring
- [ ] Add error tracking (Sentry or equivalent)
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
