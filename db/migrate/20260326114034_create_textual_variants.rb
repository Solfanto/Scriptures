class CreateTextualVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :textual_variants do |t|
      t.references :passage, null: false, foreign_key: true
      t.references :manuscript, null: false, foreign_key: true
      t.text :text, null: false
      t.text :notes

      t.timestamps
    end

    add_index :textual_variants, [ :passage_id, :manuscript_id ], unique: true
  end
end
