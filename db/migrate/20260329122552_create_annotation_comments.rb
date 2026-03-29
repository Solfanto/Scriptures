class CreateAnnotationComments < ActiveRecord::Migration[8.1]
  def change
    create_table :annotation_comments do |t|
      t.references :annotation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
