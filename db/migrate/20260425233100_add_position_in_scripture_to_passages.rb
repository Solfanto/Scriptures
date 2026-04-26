class AddPositionInScriptureToPassages < ActiveRecord::Migration[8.1]
  def up
    add_column :passages, :position_in_scripture, :integer

    Scripture.reset_column_information
    Division.reset_column_information
    Passage.reset_column_information

    Scripture.find_each do |scripture|
      counter = 0
      walk = ->(divisions) do
        divisions.order(:position).each do |division|
          division.passages.order(:position).each do |passage|
            counter += 1
            passage.update_column(:position_in_scripture, counter)
          end
          walk.call(division.children)
        end
      end
      walk.call(scripture.divisions.where(parent_id: nil))
    end

    change_column_null :passages, :position_in_scripture, false
    add_index :passages, [ :division_id, :position_in_scripture ],
      name: "index_passages_on_division_id_and_position_in_scripture"
  end

  def down
    remove_index :passages, name: "index_passages_on_division_id_and_position_in_scripture"
    remove_column :passages, :position_in_scripture
  end
end
