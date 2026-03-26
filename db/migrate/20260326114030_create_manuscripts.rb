class CreateManuscripts < ActiveRecord::Migration[8.1]
  def change
    create_table :manuscripts do |t|
      t.string :name, null: false
      t.string :abbreviation, null: false
      t.string :date_description
      t.string :language
      t.references :corpus, null: false, foreign_key: { to_table: :corpora }
      t.text :description

      t.timestamps
    end

    add_index :manuscripts, [ :corpus_id, :abbreviation ], unique: true
  end
end
