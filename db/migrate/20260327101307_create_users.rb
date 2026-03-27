class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest
      t.string :display_name
      t.string :default_corpus_slug
      t.string :default_translation_abbreviation
      t.string :language, default: "en"

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
