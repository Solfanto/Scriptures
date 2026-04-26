# Scriptures

A tool for studying scriptures — compare translations, annotate passages, and share your notes.

The primary audience is atheist religion scholars: academics and researchers who approach scripture as historical, literary, and cultural texts rather than objects of faith. The UI, features, and framing should reflect a critical, comparative, and non-devotional perspective.

## Features

**Study depth**
- **Translations** — Access multiple public domain translations side by side
- **Comparison** — Compare passages across versions and translations
- **Translation diff** — Visual word-level diff between two translations to highlight interpretive choices
- **Intertextual links** — Cross-tradition parallel passages with relationship types (literary dependence, shared source, allusion, quotation)
- **Source criticism** — Colour-coded source layers (J/E/D/P, Q source, etc.) with scholarly attribution
- **Textual criticism** — Manuscript variants and critical apparatus inline
- **Word study** — Original language (Hebrew/Greek/Arabic/Sanskrit) with lexicon definitions
- **Commentary** — Critical and historical-critical commentaries alongside text
- **LLM translations** — AI-generated translations from original languages reflecting authorial intent from a secular, historical perspective: word-for-word and easy-read modes

**Organization**
- **Annotations** — Add personal notes and tags to any passage
- **Highlights** — Color-coded highlighting by theme, separate from annotations
- **Collections** — Curate thematic passage sets (e.g. "Punishment")
- **Bookmarks** — Quick-access saved locations

**Reading**
- **Research curricula** — Structured reading sequences modelled on academic syllabi (e.g. "Introduction to the Hebrew Bible", "Comparative flood narratives")
- **Featured passage** — Periodically rotated passage with historical and critical context
- **Offline access** — Cache translations locally for use without a connection

**Sharing & export**
- **Sharing** — Export and import annotations with others
- **Citation formatting** — Copy passages in standard formats (MLA, Chicago, plain)
- **PDF/print export** — Formatted for printing or study handouts

**Discovery**
- **Search** — Full-text search across scripture text and annotations
- **Concordance** — Every occurrence of a word across all books
- **Statistics** — Reading history and progress visualization

## Scriptures

**Christian**
- Old Testament / Hebrew Bible
- New Testament
- Deuterocanon / Apocrypha (Catholic & Orthodox)

**Jewish**
- Torah (Genesis–Deuteronomy)
- Nevi'im (Prophets)
- Ketuvim (Writings)
- Mishnah
- Talmud (Babylonian & Jerusalem)

**Islamic**
- Quran
- Hadith collections (Bukhari, Muslim, etc.)
- Sira (biography of the Prophet)
- Tafsir (Quranic exegesis)

**Hindu**
- Vedas (Rigveda, Samaveda, Yajurveda, Atharvaveda)
- Upanishads
- Bhagavad Gita
- Ramayana
- Mahabharata
- Puranas

**Buddhist**
- Tripitaka / Pali Canon
- Dhammapada
- Heart Sutra
- Diamond Sutra

**Latter-day Saint**
- Book of Mormon
- Doctrine and Covenants
- Pearl of Great Price

**Sikh**
- Guru Granth Sahib

**Zoroastrian**
- Avesta

**Taoist**
- Tao Te Ching
- Zhuangzi

**Confucian**
- Analects
- Five Classics (I Ching, Book of Odes, etc.)

**Bahai**
- Kitáb-i-Aqdas
- Kitáb-i-Íqán
- Hidden Words

**Jain**
- Agamas
- Tattvartha Sutra

**Shinto**
- Kojiki
- Nihon Shoki

**Gnostic**
- Nag Hammadi library (Gospel of Thomas, Gospel of Philip, etc.)

**Mandaean**
- Ginza Rba

**Yazidi**
- Kitêba Cilwe
- Mishefa Reş

**Dead Sea Scrolls**

**Ancient & historical**
- Egyptian Book of the Dead
- Pyramid Texts
- Enuma Elish
- Epic of Gilgamesh
- Prose Edda & Poetic Edda (Norse)
- Popol Vuh (Maya)

## Documentation

- [Data model](docs/DATA_MODEL.md) — how traditions, scriptures, passages, and translations are organized in the database

## Requirements

- Ruby 4
- PostgreSQL

## Setup

```bash
bundle install
bin/setup
bin/dev
```

## Development

```bash
bin/rails test        # unit and integration tests
bin/rails test:system # system tests (requires Chrome)
bin/brakeman          # security scan
bin/rubocop           # code style
```

## Deployment

Deployment is managed with [Kamal](https://kamal-deploy.org). Configure your server and registry in `config/deploy.yml`, then:

```bash
kamal setup   # first deploy
kamal deploy  # subsequent deploys
```
