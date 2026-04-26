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

ActiveRecord::Schema[8.1].define(version: 2026_04_25_233400) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "annotation_comments", force: :cascade do |t|
    t.bigint "annotation_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["annotation_id"], name: "index_annotation_comments_on_annotation_id"
    t.index ["user_id"], name: "index_annotation_comments_on_user_id"
  end

  create_table "annotation_tags", force: :cascade do |t|
    t.bigint "annotation_id", null: false
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["annotation_id", "tag_id"], name: "index_annotation_tags_on_annotation_id_and_tag_id", unique: true
    t.index ["annotation_id"], name: "index_annotation_tags_on_annotation_id"
    t.index ["tag_id"], name: "index_annotation_tags_on_tag_id"
  end

  create_table "annotations", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "group_id"
    t.bigint "passage_id", null: false
    t.boolean "public", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_annotations_on_group_id"
    t.index ["passage_id"], name: "index_annotations_on_passage_id"
    t.index ["user_id", "passage_id"], name: "index_annotations_on_user_id_and_passage_id"
    t.index ["user_id"], name: "index_annotations_on_user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "passage_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["passage_id"], name: "index_bookmarks_on_passage_id"
    t.index ["user_id", "passage_id"], name: "index_bookmarks_on_user_id_and_passage_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "collection_passages", force: :cascade do |t|
    t.bigint "collection_id", null: false
    t.datetime "created_at", null: false
    t.bigint "passage_id", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["collection_id", "passage_id"], name: "index_collection_passages_on_collection_id_and_passage_id", unique: true
    t.index ["collection_id"], name: "index_collection_passages_on_collection_id"
    t.index ["passage_id"], name: "index_collection_passages_on_passage_id"
  end

  create_table "collections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "group_id"
    t.string "name", null: false
    t.boolean "public", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_collections_on_group_id"
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "commentaries", force: :cascade do |t|
    t.string "author", null: false
    t.text "body", null: false
    t.string "commentary_type", null: false
    t.datetime "created_at", null: false
    t.bigint "passage_id", null: false
    t.string "source"
    t.datetime "updated_at", null: false
    t.index ["passage_id", "commentary_type"], name: "index_commentaries_on_passage_id_and_commentary_type"
    t.index ["passage_id"], name: "index_commentaries_on_passage_id"
  end

  create_table "composition_dates", force: :cascade do |t|
    t.text "citation"
    t.string "confidence"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "earliest_year"
    t.integer "latest_year"
    t.bigint "scripture_id", null: false
    t.datetime "updated_at", null: false
    t.index ["scripture_id"], name: "index_composition_dates_on_scripture_id"
  end

  create_table "corpora", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.bigint "tradition_id", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_corpora_on_slug", unique: true
    t.index ["tradition_id"], name: "index_corpora_on_tradition_id"
  end

  create_table "curricula", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "curriculum_type"
    t.text "description"
    t.bigint "group_id"
    t.string "name", null: false
    t.boolean "public", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id"], name: "index_curricula_on_group_id"
    t.index ["user_id"], name: "index_curricula_on_user_id"
  end

  create_table "curriculum_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "curriculum_id", null: false
    t.text "notes"
    t.bigint "passage_id", null: false
    t.integer "position", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["curriculum_id", "passage_id"], name: "index_curriculum_items_on_curriculum_id_and_passage_id", unique: true
    t.index ["curriculum_id"], name: "index_curriculum_items_on_curriculum_id"
    t.index ["passage_id"], name: "index_curriculum_items_on_passage_id"
  end

  create_table "divisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "number"
    t.bigint "parent_id"
    t.integer "position"
    t.bigint "scripture_id", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_divisions_on_parent_id"
    t.index ["scripture_id", "number"], name: "index_divisions_on_scripture_id_and_number"
    t.index ["scripture_id"], name: "index_divisions_on_scripture_id"
  end

  create_table "featured_passages", force: :cascade do |t|
    t.date "active_from", null: false
    t.date "active_until"
    t.text "context", null: false
    t.datetime "created_at", null: false
    t.bigint "passage_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["active_from"], name: "index_featured_passages_on_active_from"
    t.index ["passage_id"], name: "index_featured_passages_on_passage_id"
  end

  create_table "group_activities", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.bigint "trackable_id", null: false
    t.string "trackable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id", "created_at"], name: "index_group_activities_on_group_id_and_created_at"
    t.index ["group_id"], name: "index_group_activities_on_group_id"
    t.index ["trackable_type", "trackable_id"], name: "index_group_activities_on_trackable_type_and_trackable_id"
    t.index ["user_id"], name: "index_group_activities_on_user_id"
  end

  create_table "group_invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "group_id", null: false
    t.bigint "invited_by_id", null: false
    t.string "role", default: "viewer", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_group_invitations_on_email"
    t.index ["group_id"], name: "index_group_invitations_on_group_id"
    t.index ["invited_by_id"], name: "index_group_invitations_on_invited_by_id"
    t.index ["token"], name: "index_group_invitations_on_token", unique: true
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.string "role", default: "viewer", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["group_id", "user_id"], name: "index_group_memberships_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "owner_id", null: false
    t.boolean "public", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_groups_on_owner_id"
  end

  create_table "highlights", force: :cascade do |t|
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.integer "end_offset", null: false
    t.string "label"
    t.bigint "passage_id", null: false
    t.integer "start_offset", null: false
    t.bigint "translation_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["passage_id"], name: "index_highlights_on_passage_id"
    t.index ["translation_id"], name: "index_highlights_on_translation_id"
    t.index ["user_id"], name: "index_highlights_on_user_id"
  end

  create_table "import_runs", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "key", null: false
    t.integer "processed_count", default: 0
    t.integer "records_count", default: 0
    t.datetime "started_at"
    t.string "status", default: "pending", null: false
    t.integer "total_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_import_runs_on_key"
    t.index ["status"], name: "index_import_runs_on_status"
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
    t.string "browser_token", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "short_code", default: "", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["browser_token"], name: "index_magic_tokens_on_browser_token"
    t.index ["short_code"], name: "index_magic_tokens_on_short_code"
    t.index ["token"], name: "index_magic_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_magic_tokens_on_user_id"
  end

  create_table "manuscripts", force: :cascade do |t|
    t.string "abbreviation", null: false
    t.bigint "corpus_id", null: false
    t.datetime "created_at", null: false
    t.string "date_description"
    t.text "description"
    t.string "facsimile_url"
    t.string "language"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["corpus_id", "abbreviation"], name: "index_manuscripts_on_corpus_id_and_abbreviation", unique: true
    t.index ["corpus_id"], name: "index_manuscripts_on_corpus_id"
  end

  create_table "original_language_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "lemma"
    t.bigint "lexicon_entry_id"
    t.string "morphology"
    t.bigint "passage_id", null: false
    t.integer "position", null: false
    t.string "text", null: false
    t.string "transliteration"
    t.datetime "updated_at", null: false
    t.index ["lemma"], name: "index_original_language_tokens_on_lemma"
    t.index ["lexicon_entry_id"], name: "index_original_language_tokens_on_lexicon_entry_id"
    t.index ["passage_id", "position"], name: "index_original_language_tokens_on_passage_id_and_position", unique: true
    t.index ["passage_id"], name: "index_original_language_tokens_on_passage_id"
  end

  create_table "parallel_passages", force: :cascade do |t|
    t.text "citation"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "parallel_passage_id", null: false
    t.bigint "passage_id", null: false
    t.string "relationship_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["parallel_passage_id"], name: "index_parallel_passages_on_parallel_passage_id"
    t.index ["passage_id", "parallel_passage_id"], name: "index_parallel_passages_on_passage_id_and_parallel_passage_id", unique: true
    t.index ["passage_id"], name: "index_parallel_passages_on_passage_id"
    t.index ["user_id"], name: "index_parallel_passages_on_user_id"
  end

  create_table "passage_source_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "passage_id", null: false
    t.bigint "source_document_id", null: false
    t.datetime "updated_at", null: false
    t.index ["passage_id"], name: "index_passage_source_documents_on_passage_id"
    t.index ["source_document_id"], name: "index_passage_source_documents_on_source_document_id"
  end

  create_table "passages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "division_id", null: false
    t.integer "number"
    t.integer "position"
    t.integer "position_in_scripture", null: false
    t.datetime "updated_at", null: false
    t.index ["division_id", "number"], name: "index_passages_on_division_id_and_number"
    t.index ["division_id", "position_in_scripture"], name: "index_passages_on_division_id_and_position_in_scripture"
    t.index ["division_id"], name: "index_passages_on_division_id"
  end

  create_table "passkey_credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.string "label"
    t.text "public_key", null: false
    t.integer "sign_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["external_id"], name: "index_passkey_credentials_on_external_id", unique: true
    t.index ["user_id"], name: "index_passkey_credentials_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "score", null: false
    t.bigint "translation_segment_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["translation_segment_id"], name: "index_ratings_on_translation_segment_id"
    t.index ["user_id", "translation_segment_id"], name: "index_ratings_on_user_id_and_translation_segment_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "reading_progresses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "passage_id", null: false
    t.datetime "read_at", null: false
    t.integer "time_spent_seconds", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["passage_id"], name: "index_reading_progresses_on_passage_id"
    t.index ["user_id", "passage_id"], name: "index_reading_progresses_on_user_id_and_passage_id", unique: true
    t.index ["user_id"], name: "index_reading_progresses_on_user_id"
  end

  create_table "scriptures", force: :cascade do |t|
    t.bigint "corpus_id", null: false
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
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "source_documents", force: :cascade do |t|
    t.string "abbreviation"
    t.string "bibliography_url"
    t.string "color"
    t.bigint "corpus_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["abbreviation"], name: "index_source_documents_on_abbreviation"
    t.index ["corpus_id"], name: "index_source_documents_on_corpus_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "textual_variants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "manuscript_id", null: false
    t.text "notes"
    t.bigint "passage_id", null: false
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

  create_table "translation_segments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "end_passage_id", null: false
    t.integer "end_position", null: false
    t.bigint "scripture_id", null: false
    t.tsvector "search_vector"
    t.bigint "start_passage_id", null: false
    t.integer "start_position", null: false
    t.text "text", null: false
    t.bigint "translation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["end_passage_id"], name: "index_translation_segments_on_end_passage_id"
    t.index ["scripture_id"], name: "index_translation_segments_on_scripture_id"
    t.index ["search_vector"], name: "index_translation_segments_on_search_vector", using: :gin
    t.index ["start_passage_id"], name: "index_translation_segments_on_start_passage_id"
    t.index ["translation_id", "scripture_id", "start_position", "end_position"], name: "index_translation_segments_on_range"
    t.index ["translation_id", "start_passage_id", "end_passage_id"], name: "index_translation_segments_on_translation_and_bounds", unique: true
    t.index ["translation_id"], name: "index_translation_segments_on_translation_id"
  end

  create_table "translations", force: :cascade do |t|
    t.string "abbreviation"
    t.bigint "corpus_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "edition_type"
    t.string "language"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["abbreviation"], name: "index_translations_on_abbreviation"
    t.index ["corpus_id"], name: "index_translations_on_corpus_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "default_corpus_slug"
    t.string "default_translation_abbreviation"
    t.string "display_name"
    t.string "email", null: false
    t.string "language", default: "en"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "annotation_comments", "annotations"
  add_foreign_key "annotation_comments", "users"
  add_foreign_key "annotation_tags", "annotations"
  add_foreign_key "annotation_tags", "tags"
  add_foreign_key "annotations", "groups"
  add_foreign_key "annotations", "passages"
  add_foreign_key "annotations", "users"
  add_foreign_key "bookmarks", "passages"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "collection_passages", "collections"
  add_foreign_key "collection_passages", "passages"
  add_foreign_key "collections", "groups"
  add_foreign_key "collections", "users"
  add_foreign_key "commentaries", "passages"
  add_foreign_key "composition_dates", "scriptures"
  add_foreign_key "corpora", "traditions"
  add_foreign_key "curricula", "groups"
  add_foreign_key "curricula", "users"
  add_foreign_key "curriculum_items", "curricula"
  add_foreign_key "curriculum_items", "passages"
  add_foreign_key "divisions", "divisions", column: "parent_id"
  add_foreign_key "divisions", "scriptures"
  add_foreign_key "featured_passages", "passages"
  add_foreign_key "group_activities", "groups"
  add_foreign_key "group_activities", "users"
  add_foreign_key "group_invitations", "groups"
  add_foreign_key "group_invitations", "users", column: "invited_by_id"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "groups", "users", column: "owner_id"
  add_foreign_key "highlights", "passages"
  add_foreign_key "highlights", "translations"
  add_foreign_key "highlights", "users"
  add_foreign_key "magic_tokens", "users"
  add_foreign_key "manuscripts", "corpora", column: "corpus_id"
  add_foreign_key "original_language_tokens", "lexicon_entries"
  add_foreign_key "original_language_tokens", "passages"
  add_foreign_key "parallel_passages", "passages"
  add_foreign_key "parallel_passages", "passages", column: "parallel_passage_id"
  add_foreign_key "parallel_passages", "users"
  add_foreign_key "passage_source_documents", "passages"
  add_foreign_key "passage_source_documents", "source_documents"
  add_foreign_key "passages", "divisions"
  add_foreign_key "passkey_credentials", "users"
  add_foreign_key "ratings", "translation_segments"
  add_foreign_key "ratings", "users"
  add_foreign_key "reading_progresses", "passages"
  add_foreign_key "reading_progresses", "users"
  add_foreign_key "scriptures", "corpora", column: "corpus_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "source_documents", "corpora", column: "corpus_id"
  add_foreign_key "tags", "users"
  add_foreign_key "textual_variants", "manuscripts"
  add_foreign_key "textual_variants", "passages"
  add_foreign_key "translation_segments", "passages", column: "end_passage_id"
  add_foreign_key "translation_segments", "passages", column: "start_passage_id"
  add_foreign_key "translation_segments", "scriptures"
  add_foreign_key "translation_segments", "translations"
  add_foreign_key "translations", "corpora", column: "corpus_id"
end
