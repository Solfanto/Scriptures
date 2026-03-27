class CreateMagicTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :magic_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :magic_tokens, :token, unique: true
  end
end
