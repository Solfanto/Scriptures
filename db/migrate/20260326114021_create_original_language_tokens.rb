class CreateOriginalLanguageTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :original_language_tokens do |t|
      t.references :passage, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :text, null: false
      t.string :transliteration
      t.string :lemma
      t.string :morphology
      t.references :lexicon_entry, foreign_key: true

      t.timestamps
    end

    add_index :original_language_tokens, [ :passage_id, :position ], unique: true
  end
end
