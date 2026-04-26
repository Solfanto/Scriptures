class CreateTranslationSegments < ActiveRecord::Migration[8.1]
  def up
    create_table :translation_segments do |t|
      t.references :translation, null: false, foreign_key: true
      t.references :scripture, null: false, foreign_key: true
      t.references :start_passage, null: false, foreign_key: { to_table: :passages }
      t.references :end_passage, null: false, foreign_key: { to_table: :passages }
      t.integer :start_position, null: false
      t.integer :end_position, null: false
      t.text :text, null: false
      t.tsvector :search_vector

      t.timestamps
    end

    add_index :translation_segments, [ :translation_id, :scripture_id, :start_position, :end_position ],
      name: "index_translation_segments_on_range"
    add_index :translation_segments, [ :translation_id, :start_passage_id, :end_passage_id ],
      unique: true, name: "index_translation_segments_on_translation_and_bounds"
    add_index :translation_segments, :search_vector, using: :gin

    execute <<~SQL
      CREATE OR REPLACE FUNCTION translation_segments_search_vector_update() RETURNS trigger AS $$
      BEGIN
        NEW.search_vector := to_tsvector('simple', COALESCE(NEW.text, ''));
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<~SQL
      CREATE TRIGGER translation_segments_search_vector_trigger
      BEFORE INSERT OR UPDATE OF text ON translation_segments
      FOR EACH ROW EXECUTE FUNCTION translation_segments_search_vector_update();
    SQL

    # Copy passage_translations → translation_segments, preserving IDs so existing
    # ratings.passage_translation_id values remain valid after the column rename.
    execute <<~SQL
      INSERT INTO translation_segments (
        id, translation_id, scripture_id,
        start_passage_id, end_passage_id,
        start_position, end_position,
        text, created_at, updated_at
      )
      SELECT
        pt.id,
        pt.translation_id,
        d.scripture_id,
        pt.passage_id, pt.passage_id,
        p.position_in_scripture, p.position_in_scripture,
        pt.text, pt.created_at, pt.updated_at
      FROM passage_translations pt
      JOIN passages p ON p.id = pt.passage_id
      JOIN divisions d ON d.id = p.division_id;
    SQL

    execute <<~SQL
      SELECT setval(
        pg_get_serial_sequence('translation_segments', 'id'),
        COALESCE((SELECT MAX(id) FROM translation_segments), 0) + 1,
        false
      );
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS translation_segments_search_vector_trigger ON translation_segments;"
    execute "DROP FUNCTION IF EXISTS translation_segments_search_vector_update();"
    drop_table :translation_segments
  end
end
