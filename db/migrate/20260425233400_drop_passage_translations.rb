class DropPassageTranslations < ActiveRecord::Migration[8.1]
  def up
    execute "DROP TRIGGER IF EXISTS passage_translations_search_vector_trigger ON passage_translations;"
    execute "DROP FUNCTION IF EXISTS passage_translations_search_vector_update();"
    drop_table :passage_translations
  end

  def down
    create_table :passage_translations do |t|
      t.references :passage, null: false, foreign_key: true
      t.references :translation, null: false, foreign_key: true
      t.text :text, null: false
      t.tsvector :search_vector
      t.timestamps
    end

    add_index :passage_translations, [ :passage_id, :translation_id ], unique: true
    add_index :passage_translations, :search_vector, using: :gin

    execute <<~SQL
      CREATE OR REPLACE FUNCTION passage_translations_search_vector_update() RETURNS trigger AS $$
      BEGIN
        NEW.search_vector := to_tsvector('simple', COALESCE(NEW.text, ''));
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<~SQL
      CREATE TRIGGER passage_translations_search_vector_trigger
      BEFORE INSERT OR UPDATE OF text ON passage_translations
      FOR EACH ROW EXECUTE FUNCTION passage_translations_search_vector_update();
    SQL
  end
end
