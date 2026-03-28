class AddPublicToAnnotations < ActiveRecord::Migration[8.1]
  def change
    add_column :annotations, :public, :boolean, default: false, null: false
  end
end
