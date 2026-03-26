class CreateLexiconEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :lexicon_entries do |t|
      t.string :lemma, null: false
      t.string :language, null: false
      t.string :transliteration
      t.text :definition
      t.string :morphology_label
      t.string :strongs_number

      t.timestamps
    end

    add_index :lexicon_entries, :strongs_number, unique: true
    add_index :lexicon_entries, [ :lemma, :language ]
  end
end
