class CreateCommentaries < ActiveRecord::Migration[8.1]
  def change
    create_table :commentaries do |t|
      t.references :passage, null: false, foreign_key: true
      t.string :author, null: false
      t.string :source
      t.text :body, null: false
      t.string :commentary_type, null: false

      t.timestamps
    end
    add_index :commentaries, [ :passage_id, :commentary_type ]
  end
end
