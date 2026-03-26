class CreateCompositionDates < ActiveRecord::Migration[8.1]
  def change
    create_table :composition_dates do |t|
      t.references :scripture, null: false, foreign_key: true
      t.integer :earliest_year
      t.integer :latest_year
      t.string :confidence
      t.text :description
      t.text :citation

      t.timestamps
    end
  end
end
