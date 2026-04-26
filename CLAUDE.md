# Scriptures

A scripture study tool for atheist religion scholars — compare translations, annotate passages, and share notes. Built with a critical, comparative, non-devotional perspective.

## Stack

- Ruby 4 / Rails 8.1 (PostgreSQL, Propshaft, Importmap)
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- Solid Cache / Solid Queue / Solid Cable
- Kamal for deployment

## Commands

```bash
bin/rails server          # start dev server
bin/rails test            # unit and integration tests
bin/rails test:system     # system tests (requires Chrome)
bin/rubocop               # lint (Rails Omakase style)
bin/brakeman              # security scan
bin/rails db:seed          # seed traditions, corpora, scriptures, and Genesis 1:1-5
```

## Architecture

### Data model

Tradition → Corpus → Scripture → Division → Passage; text via TranslationSegment (range-based)

- `Tradition` — religious tradition (Jewish, Christian, Islamic, Ancient & Historical)
- `Corpus` — top-level grouping within a tradition (Bible, New Testament, Quran)
- `Scripture` — a named text within a corpus (Genesis, Matthew)
- `Division` — recursive (self-referential via `parent_id`) for chapters, books, parts
- `Passage` — the atomic unit of text (verse, stanza, line); carries `position_in_scripture` for range comparisons
- `Translation` — a named version of a corpus in a given language (KJV, WLC, LXX)
- `TranslationSegment` — the translated text covering a contiguous range of passages (`start_passage`..`end_passage`); single-passage segments have start = end, range segments cover summaries/pericopes
- `SourceDocument` — hypothetical source layers (J, E, D, P) with color coding
- `PassageSourceDocument` — join table linking passages to source documents

See [docs/DATA_MODEL.md](docs/DATA_MODEL.md) for the full data model.

### Routes

- `/traditions` — browse by tradition
- `/:corpus_slug/:scripture_slug/:division_number` — canonical passage URL (e.g. `/bible/genesis/1`)
- `/search` — full-text search
- Root redirects to the default reading view

### Frontend

- Stimulus controllers in `app/javascript/controllers/`
- Use native private fields (`#field`) in Stimulus controllers
- Tailwind for all styling — no custom CSS classes

## Workflow

- Update `ROADMAP.md` as you complete tasks — check off items with `[x]` as they are implemented

## Conventions

- Use `find_or_create_by!` with blocks in seeds for idempotency
- Models use slugs for URL-friendly identifiers
- Positions are 1-indexed integers for ordering
- Follow Rails Omakase rubocop style (inherit from `rubocop-rails-omakase`)
- Minitest for testing (not RSpec)
- Tests run in parallel
- Fixtures for test data
