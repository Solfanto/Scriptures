class RenameRatingsPassageTranslationToSegment < ActiveRecord::Migration[8.1]
  def up
    remove_foreign_key :ratings, :passage_translations
    remove_index :ratings, name: "index_ratings_on_passage_translation_id"
    remove_index :ratings, name: "index_ratings_on_user_id_and_passage_translation_id"

    rename_column :ratings, :passage_translation_id, :translation_segment_id

    add_index :ratings, :translation_segment_id
    add_index :ratings, [ :user_id, :translation_segment_id ], unique: true
    add_foreign_key :ratings, :translation_segments
  end

  def down
    remove_foreign_key :ratings, :translation_segments
    remove_index :ratings, name: "index_ratings_on_user_id_and_translation_segment_id"
    remove_index :ratings, :translation_segment_id

    rename_column :ratings, :translation_segment_id, :passage_translation_id

    add_index :ratings, :passage_translation_id
    add_index :ratings, [ :user_id, :passage_translation_id ], unique: true
    add_foreign_key :ratings, :passage_translations
  end
end
