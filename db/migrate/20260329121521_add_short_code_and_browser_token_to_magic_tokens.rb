class AddShortCodeAndBrowserTokenToMagicTokens < ActiveRecord::Migration[8.1]
  def change
    add_column :magic_tokens, :short_code, :string, null: false, default: ""
    add_column :magic_tokens, :browser_token, :string, null: false, default: ""
    add_index :magic_tokens, :short_code
    add_index :magic_tokens, :browser_token
  end
end
