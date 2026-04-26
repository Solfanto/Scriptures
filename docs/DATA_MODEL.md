# Data model: how scriptures are organized

Scripture content is organized along two orthogonal axes:

1. **Structural hierarchy** — where a passage sits (tradition → book → chapter → verse)
2. **Translation** — what words render that passage (KJV, WLC, LXX, …)

A `Passage` is the atomic structural unit. Its *text* does not live on the passage itself; it lives in `TranslationSegment`, where each segment covers a contiguous range of passages — anywhere from one verse to a whole pericope. A normal verse-by-verse translation has one segment per passage (start = end). A summary or paraphrase translation can have one segment covering many passages.

## Structural hierarchy

```
Tradition
  └── Corpus
        └── Scripture
              └── Division  (recursive via parent_id)
                    └── Passage
```

### Tradition

A religious or cultural tradition. Examples: `jewish`, `christian`, `islamic`, `ancient-historical`.

- Unique `slug` used in URLs and lookups
- Has many `Corpus` records

### Corpus

A top-level grouping of scriptures within a tradition. Examples: `bible`, `new-testament`, `quran`, `pali-canon`.

- Belongs to a `Tradition`
- Unique `slug` (globally, not just within tradition)
- Has many `Scripture`, `Translation`, `SourceDocument`, and `Manuscript` records

Translations, source documents, and manuscripts attach at the corpus level because they typically span multiple scriptures (e.g. the KJV is one translation covering all 66 books of the Protestant Bible).

### Scripture

A named text within a corpus. Examples: `genesis`, `matthew`, `surah-al-fatiha`.

- Belongs to a `Corpus`
- `slug` is unique per corpus (so `bible/genesis` and a hypothetical other corpus's `genesis` can coexist)
- `position` orders scriptures within the corpus (1-indexed)
- Has many `Division` and `CompositionDate` records

### Division

The recursive mid-level structure. A division may be a chapter, a book grouping, a part, a sura, a canto — whatever the scripture's native organization uses. Divisions nest via `parent_id`.

- Belongs to a `Scripture`
- Optional `parent` (another `Division` in the same scripture)
- `number` is the native reference number (e.g. chapter 1)
- `position` orders siblings within a parent (1-indexed)
- `name` is a display label; falls back to `"Chapter #{number}"` when blank
- Has many child `Division`s and many `Passage`s

Example shapes:

- **Genesis**: `Scripture "Genesis"` → flat list of `Division` rows, one per chapter → each holds its verses as `Passage`s.
- **Tanakh**-style grouping: `Scripture` → top-level `Division` ("Torah") → child `Division` ("Genesis") → leaf `Division`s per chapter.
- **Quran**: `Scripture "Quran"` → `Division` per sura → `Passage` per ayah.

Passages always hang off a **leaf** division. A division with children typically has no passages of its own.

### Passage

The atomic unit — a verse, ayah, stanza, or line.

- Belongs to a `Division`
- `number` is the native reference (verse 1, ayah 3, …)
- `position` orders passages within a division (1-indexed)
- `position_in_scripture` is a 1-indexed sequential position across the entire scripture (used for range comparisons against `TranslationSegment` bounds)
- `delegate :scripture, to: :division` lets callers walk up without hand-threading
- Default scope: `order(:position)`

A passage carries *no text of its own*. To read it, find the covering `TranslationSegment`.

## Translation axis

```
Corpus ──< Translation ──< TranslationSegment >── Passage (start_passage / end_passage)
```

### Translation

A specific version of a corpus in a given language. Examples: `KJV`, `WLC` (Westminster Leningrad Codex), `LXX` (Septuagint), `NRSV`.

- Belongs to a `Corpus`
- `edition_type` is one of `critical`, `devotional`, or `original` (used to filter translations for scholarly vs. devotional vs. source-language views)
- `language` and `abbreviation` for display

### TranslationSegment

The actual text of a contiguous range of passages in a specific translation. The segment carries the content.

- Belongs to a `Translation`, a `Scripture`, a `start_passage`, and an `end_passage`
- `text` (not null) is the rendered text for the range
- `start_position` / `end_position` are denormalized copies of `start_passage.position_in_scripture` and `end_passage.position_in_scripture`, used for cheap range-overlap queries
- `start_passage_id == end_passage_id` for verse-by-verse translations (the common case)
- `start_passage_id != end_passage_id` for summaries, paraphrases, and pericope-level translations
- Unique on `(translation_id, start_passage_id, end_passage_id)` — at most one segment per exact range
- `search_vector` is a GIN-indexed `tsvector` used for full-text search

`Passage#text_for(translation)` is the standard accessor — it returns the *narrowest* covering segment's text (so a single-passage segment beats a range segment when both exist):

```ruby
passage.text_for(translation) # => "In the beginning God created..."
```

To create or update a segment programmatically:

```ruby
# Single passage (verse-by-verse import)
TranslationSegment.find_or_create_for_range(
  translation: kjv, start_passage: gen_1_1, end_passage: gen_1_1, text: "In the beginning..."
)

# Range (chapter summary, pericope)
TranslationSegment.upsert_for_range(
  translation: ai_summary, start_passage: gen_1_1, end_passage: gen_2_3,
  text: "The Priestly creation account..."
)
```

The two helpers differ in semantics: `find_or_create_for_range` is idempotent (text only set on initial create — used by importers), `upsert_for_range` always writes the text (used by the LLM job and manual edits).

**Range constraint**: ranges must be contiguous and within a single scripture. Pericopes spanning chapters are fine; pericopes spanning books are not.

## Scholarly apparatus attached to passages

Multiple scholarly layers attach to `Passage`:

- `PassageSourceDocument` — links a passage to one or more `SourceDocument`s (J, E, D, P, Q, …). Source documents live at the `Corpus` level and carry a `color` for highlighting.
- `TextualVariant` — manuscript-level variant readings. Each belongs to a `Manuscript` (also corpus-level) and holds the variant `text`.
- `OriginalLanguageToken` — token-level original-language data (Hebrew/Greek/Arabic) with optional `LexiconEntry` lookup (Strong's, lemma, morphology).
- `Commentary` — critical/historical-critical commentary, tagged by `commentary_type`.
- `ParallelPassage` — cross-references another `Passage` with a `relationship_type` (literary dependence, shared source, allusion, quotation).

## User-generated content attached to passages

- `Annotation` (with `AnnotationTag`, `AnnotationComment`) — notes, optionally public or scoped to a `Group`
- `Highlight` — color-coded ranges within a specific `(passage, translation)` pair, scoped by character offsets
- `Bookmark` — quick-access pointer
- `CollectionPassage` — membership in a user-curated `Collection`
- `CurriculumItem` — ordered step in a `Curriculum` reading sequence
- `ReadingProgress` — per-user read timestamps
- `Rating` — attached to a `TranslationSegment`, not the passage itself (users rate a specific rendering of a passage or range)

## URL conventions

Passage URLs follow the structural hierarchy via slugs and numbers:

```
/:corpus_slug/:scripture_slug/:division_number
# e.g. /bible/genesis/1
```

- `Corpus#to_param` → `slug`
- `Scripture#to_param` → `slug`
- `Tradition#to_param` → `slug`

## Positions and numbers

Two conventions coexist on `Scripture`, `Division`, and `Passage`:

- `number` — the native reference (chapter 1, verse 3). Not guaranteed sequential; texts sometimes skip or reuse numbers across traditions.
- `position` — a 1-indexed integer used for stable ordering. Default scopes order by `position`.

When seeding or importing, set both. Use `position` for iteration and UI ordering; expose `number` to users as the citation.

## Quick ERD

```
Tradition 1──n Corpus 1──n Scripture 1──n Division (recursive) 1──n Passage
                 │                            │
                 │                            └─< TranslationSegment >── Translation
                 │                                (start_passage..end_passage range)
                 │
                 1──n SourceDocument n──n Passage (via PassageSourceDocument)
                 │
                 1──n Manuscript  1──n TextualVariant n──1 Passage
```
