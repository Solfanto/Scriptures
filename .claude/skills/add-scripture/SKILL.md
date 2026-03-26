---
name: add-scripture
description: Add a new scripture to an existing corpus with seed chapters and passages. Use when the user wants to add a book or text to the database.
argument-hint: [scripture-name]
---

Add a new scripture to an existing corpus.

1. Ask for (if not provided via $ARGUMENTS):
   - Tradition and corpus (or create a new corpus if needed)
   - Scripture name and slug
   - Number of seed chapters and passages per chapter
   - Any translations to seed with sample text
2. Update `db/seeds.rb` with `find_or_create_by!` blocks for:
   - The scripture
   - Divisions (chapters) with position and number
   - Passages with position and number
   - PassageTranslations for any seeded translations
3. Follow the existing pattern in `db/seeds.rb` (see Genesis as the reference)
4. Run `bin/rails db:seed` to verify
