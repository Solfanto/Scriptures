class CreateParallelPassages < ActiveRecord::Migration[8.1]
  def change
    create_table :parallel_passages do |t|
      t.references :passage, null: false, foreign_key: true
      t.references :parallel_passage, null: false, foreign_key: { to_table: :passages }
      t.string :relationship_type, null: false
      t.text :description
      t.text :citation

      t.timestamps
    end

    add_index :parallel_passages, [ :passage_id, :parallel_passage_id ], unique: true
  end
end
