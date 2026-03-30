# == Schema Information
#
# Table name: collection_passages
#
#  id            :bigint           not null, primary key
#  position      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  collection_id :bigint           not null
#  passage_id    :bigint           not null
#
# Indexes
#
#  index_collection_passages_on_collection_id                 (collection_id)
#  index_collection_passages_on_collection_id_and_passage_id  (collection_id,passage_id) UNIQUE
#  index_collection_passages_on_passage_id                    (passage_id)
#
# Foreign Keys
#
#  fk_rails_...  (collection_id => collections.id)
#  fk_rails_...  (passage_id => passages.id)
#
class CollectionPassage < ApplicationRecord
  belongs_to :collection
  belongs_to :passage

  validates :passage_id, uniqueness: { scope: :collection_id }

  default_scope { order(:position) }
end
