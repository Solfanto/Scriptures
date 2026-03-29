class AddGroupIdToCollections < ActiveRecord::Migration[8.1]
  def change
    add_reference :collections, :group, null: true, foreign_key: true
  end
end
