class AddUserToParallelPassages < ActiveRecord::Migration[8.1]
  def change
    add_reference :parallel_passages, :user, null: true, foreign_key: true
  end
end
