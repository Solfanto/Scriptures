# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_27_101346) do
  create_table "composition_dates", force: :cascade do |t|
    t.text "citation"
    t.string "confidence"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "earliest_year"
    t.integer "latest_year"
    t.integer "scripture_id", null: false
    t.datetime "updated_at", null: false
    t.index ["scripture_id"], name: "index_composition_dates_on_scripture_id"
  end

  create_table "corpora", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "tradition_id", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_corpora_on_slug", unique: true
    t.index ["tradition_id"], name: "index_corpora_on_tradition_id"
  end

  create_table "divisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "number"
    t.integer "parent_id"
    t.integer "position"
    t.integer "scripture_id", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_divisions_on_parent_id"
    t.index ["scripture_id"], name: "index_divisions_on_scripture_id"
  end

  create_table "lexicon_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "definition"
    t.string "language", null: false
    t.string "lemma", null: false
    t.string "morphology_label"
    t.string "strongs_number"
    t.string "transliteration"
    t.datetime "updated_at", null: false
    t.index ["lemma", "language"], name: "index_lexicon_entries_on_lemma_and_language"
    t.index ["strongs_number"], name: "index_lexicon_entries_on_strongs_number", unique: true
  end

  create_table "magic_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["token"], name: "index_magic_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_magic_tokens_on_user_id"
  end

  create_table "manuscripts", force: :cascade do |t|
    t.string "abbreviation", null: false
    t.integer "corpus_id", null: false
    t.datetime "created_at", null: false
    t.string "date_description"
    t.text "description"
    t.string "language"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["corpus_id", "abbreviation"], name: "index_manuscripts_on_corpus_id_and_abbreviation", unique: true
    t.index ["corpus_id"], name: "index_manuscripts_on_corpus_id"
  end

  create_table "original_language_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "lemma"
    t.integer "lexicon_entry_id"
    t.string "morphology"
    t.integer "passage_id", null: false
    t.integer "position", null: false
    t.string "text", null: false
    t.string "transliteration"
    t.datetime "updated_at", null: false
    t.index ["lexicon_entry_id"], name: "index_original_language_tokens_on_lexicon_entry_id"
    t.index ["passage_id", "position"], name: "index_original_language_tokens_on_passage_id_and_position", unique: true
    t.index ["passage_id"], name: "index_original_language_tokens_on_passage_id"
  end

  create_table "parallel_passages", force: :cascade do |t|
    t.text "citation"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "parallel_passage_id", null: false
    t.integer "passage_id", null: false
    t.string "relationship_type", null: false
    t.datetime "updated_at", null: false
    t.index ["parallel_passage_id"], name: "index_parallel_passages_on_parallel_passage_id"
    t.index ["passage_id", "parallel_passage_id"], name: "index_parallel_passages_on_passage_id_and_parallel_passage_id", unique: true
    t.index ["passage_id"], name: "index_parallel_passages_on_passage_id"
  end

  create_table "passage_source_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "passage_id", null: false
    t.integer "source_document_id", null: false
    t.datetime "updated_at", null: false
    t.index ["passage_id"], name: "index_passage_source_documents_on_passage_id"
    t.index ["source_document_id"], name: "index_passage_source_documents_on_source_document_id"
  end

  create_table "passage_translations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "passage_id", null: false
    t.text "text", null: false
    t.integer "translation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["passage_id", "translation_id"], name: "index_passage_translations_on_passage_id_and_translation_id", unique: true
    t.index ["passage_id"], name: "index_passage_translations_on_passage_id"
    t.index ["translation_id"], name: "index_passage_translations_on_translation_id"
  end

  create_table "passages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "division_id", null: false
    t.integer "number"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["division_id"], name: "index_passages_on_division_id"
  end

  create_table "passkey_credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.string "label"
    t.text "public_key", null: false
    t.integer "sign_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["external_id"], name: "index_passkey_credentials_on_external_id", unique: true
    t.index ["user_id"], name: "index_passkey_credentials_on_user_id"
  end

  create_table "scriptures", force: :cascade do |t|
    t.integer "corpus_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["corpus_id", "slug"], name: "index_scriptures_on_corpus_id_and_slug", unique: true
    t.index ["corpus_id"], name: "index_scriptures_on_corpus_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "source_documents", force: :cascade do |t|
    t.string "abbreviation"
    t.string "color"
    t.integer "corpus_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["corpus_id"], name: "index_source_documents_on_corpus_id"
  end

  create_table "textual_variants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "manuscript_id", null: false
    t.text "notes"
    t.integer "passage_id", null: false
    t.text "text", null: false
    t.datetime "updated_at", null: false
    t.index ["manuscript_id"], name: "index_textual_variants_on_manuscript_id"
    t.index ["passage_id", "manuscript_id"], name: "index_textual_variants_on_passage_id_and_manuscript_id", unique: true
    t.index ["passage_id"], name: "index_textual_variants_on_passage_id"
  end

  create_table "traditions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_traditions_on_slug", unique: true
  end

  create_table "translations", force: :cascade do |t|
    t.string "abbreviation"
    t.integer "corpus_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "language"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["corpus_id"], name: "index_translations_on_corpus_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_corpus_slug"
    t.string "default_translation_abbreviation"
    t.string "display_name"
    t.string "email_address", null: false
    t.string "language", default: "en"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "composition_dates", "scriptures"
  add_foreign_key "corpora", "traditions"
  add_foreign_key "divisions", "divisions", column: "parent_id"
  add_foreign_key "divisions", "scriptures"
  add_foreign_key "magic_tokens", "users"
  add_foreign_key "manuscripts", "corpora", column: "corpus_id"
  add_foreign_key "original_language_tokens", "lexicon_entries"
  add_foreign_key "original_language_tokens", "passages"
  add_foreign_key "parallel_passages", "passages"
  add_foreign_key "parallel_passages", "passages", column: "parallel_passage_id"
  add_foreign_key "passage_source_documents", "passages"
  add_foreign_key "passage_source_documents", "source_documents"
  add_foreign_key "passage_translations", "passages"
  add_foreign_key "passage_translations", "translations"
  add_foreign_key "passages", "divisions"
  add_foreign_key "passkey_credentials", "users"
  add_foreign_key "scriptures", "corpora", column: "corpus_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "source_documents", "corpora", column: "corpus_id"
  add_foreign_key "textual_variants", "manuscripts"
  add_foreign_key "textual_variants", "passages"
  add_foreign_key "translations", "corpora", column: "corpus_id"
end
