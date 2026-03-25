# Mockup Prompt for Gemini

## Context

Design UI mockups for a web application called **Scriptures** — a scholarly tool for studying religious and historical texts.

**Primary audience:** Atheist religion scholars, academics, historians, and linguists who approach scripture as historical, literary, and cultural artefacts. The tone is critical and comparative, not devotional. Think academic reference tool, not church app.

**Tech stack:** Ruby on Rails, Hotwire (Turbo + Stimulus), served as a PWA. Desktop-first but must be fully responsive.

**Design direction:**
- Modern and visually impressive — this should feel like a premium, cutting-edge product, not a traditional academic tool
- Fancy CSS effects: glassmorphism panels, smooth transitions, subtle gradients, backdrop blur, layered depth with shadows, micro-animations on hover and focus
- Clean, dense, and scholarly — inspired by academic reference tools and critical editions, but elevated with contemporary UI craft
- Neutral and secular — no religious iconography, no reverent aesthetic
- High information density without feeling cluttered
- Strong typographic hierarchy; text is the product
- Support for RTL scripts (Arabic, Hebrew) alongside LTR
- Light and dark modes, with the dark mode leaning into rich deep backgrounds that make the glassy UI elements pop

---

## Screens to design

### 1. Reading view (single translation)

A passage from Genesis 1 in the Westminster Leningrad Codex (Hebrew) with the KJV translation below. Show:
- Corpus / book / chapter navigation breadcrumb at the top
- Each verse on its own line, numbered
- A word hovered, showing the tooltip: original Hebrew word + transliteration, most common English translation, and two alternative translations
- A source criticism layer active: verses colour-coded by source document (J shown in amber, P shown in blue), with a small legend
- A sidebar panel showing a brief critical commentary note for verse 1
- Toolbar icons for: parallel view, version comparison, search, annotations, collections

### 2. Parallel view (two translations)

Genesis 1:1–5 displayed in two columns side by side:
- Left: Masoretic Text (Hebrew)
- Right: Septuagint (Greek)
- Synchronised scrolling; verses aligned horizontally
- Translation diff highlighting active: words that differ between columns highlighted in yellow
- A third column partially visible, hinting that more can be added

### 3. Version comparison

The synoptic Gospels: Matthew 3:13–17, Mark 1:9–11, Luke 3:21–22 shown in three columns. Show:
- Structural differences highlighted: a verse present in Matthew and Luke but absent in Mark shown with a dashed empty row in the Mark column
- Columns labelled with scholarly dating (Mark: ~70 CE, Matthew: ~85 CE, Luke: ~85 CE)
- A banner at the top: "Sorted by composition date (scholarly consensus)"

### 4. Word study panel

Full panel (opened by clicking a word) for the Greek word λόγος (logos) in John 1:1. Show:
- The word in large type with transliteration (lógos) and pronunciation
- Morphological parsing: noun, masculine, nominative, singular
- Lexicon definition from a critical lexicon
- A frequency chart: occurrences across the NT
- A list of how 6 different translations rendered this specific instance
- A concordance list of other occurrences in John, scrollable

### 5. Search results

A search for "flood" scoped to "All traditions". Show:
- Results grouped by tradition: Bible (14), Quran (3), Epic of Gilgamesh (8), Hindu texts (5), Norse (2)
- Each result shows: corpus name, passage reference, a snippet with the search term highlighted
- Filters on the left: tradition, corpus, date range of composition, translation
- A toggle: "Show intertextual links" — when on, groups parallel passages together (e.g. Genesis 6–9 and Gilgamesh XI shown as a linked pair)

### 6. Annotations & collections sidebar

A slide-in right panel over the reading view showing:
- Three tabs: Annotations, Highlights, Collections
- Annotations tab active: a list of user notes attached to passages, each showing passage reference, a snippet of the note text, tags (e.g. "source criticism", "redaction"), and a group badge ("Seminar Group — HB 301")
- One annotation expanded showing the full Lexxy rich-text note

### 7. Group workspace

A group page for "Seminar: Introduction to the Hebrew Bible". Show:
- Group name, member avatars (6 members), role badges
- A shared research curriculum: "12-week reading sequence" with progress bars per member
- An activity feed: "Alice highlighted Genesis 2:4 · 2h ago", "Bob added an annotation to Exodus 20:1 · 5h ago"
- A shared collections section with two collections: "Creation narratives" and "Covenant texts"
- A "Currently reading" section showing live presence: two members shown as active on specific passages

### 8. Mobile reading view

The same reading view as screen 1 but on a 390px wide mobile screen:
- Single translation visible; swipe hint for parallel view
- Bottom navigation bar: Read, Search, Annotations, Collections, Profile
- Word tap opens the tooltip as a bottom sheet
- Source criticism layer toggle accessible via a floating button

---

## Notes for Gemini

- Use a neutral, sans-serif typeface for UI chrome and a serif or monospace for scripture text
- Passage text should feel like reading a critical edition, not a Bible app
- Avoid blues and greens associated with devotional apps; prefer slate, stone, and amber accents
- Every screen should include both a light mode and dark mode variant
- Label all UI elements clearly so the mockups can be used directly as a reference for development
