class CreateGroupActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :group_activities do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :trackable_type, null: false
      t.bigint :trackable_id, null: false

      t.timestamps
    end

    add_index :group_activities, [ :trackable_type, :trackable_id ]
    add_index :group_activities, [ :group_id, :created_at ]
  end
end
