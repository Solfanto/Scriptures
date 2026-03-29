class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # Search columns queried standalone
    add_index :translations, :abbreviation
    add_index :source_documents, :abbreviation
    add_index :group_invitations, :email

    # Composite indexes for common query patterns
    add_index :divisions, [ :scripture_id, :number ]
    add_index :passages, [ :division_id, :number ]
    add_index :commentaries, :passage_id, if_not_exists: true
  end
end
