# == Schema Information
#
# Table name: parallel_passages
# Database name: primary
#
#  id                  :bigint           not null, primary key
#  citation            :text
#  description         :text
#  relationship_type   :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parallel_passage_id :bigint           not null
#  passage_id          :bigint           not null
#  user_id             :bigint
#
# Indexes
#
#  index_parallel_passages_on_parallel_passage_id                 (parallel_passage_id)
#  index_parallel_passages_on_passage_id                          (passage_id)
#  index_parallel_passages_on_passage_id_and_parallel_passage_id  (passage_id,parallel_passage_id) UNIQUE
#  index_parallel_passages_on_user_id                             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (parallel_passage_id => passages.id)
#  fk_rails_...  (passage_id => passages.id)
#  fk_rails_...  (user_id => users.id)
#
class ParallelPassage < ApplicationRecord
  RELATIONSHIP_TYPES = %w[
    literary_dependence
    shared_source
    allusion
    typology
    quotation
  ].freeze

  belongs_to :passage
  belongs_to :parallel_passage, class_name: "Passage"
  belongs_to :user, optional: true

  validates :relationship_type, presence: true, inclusion: { in: RELATIONSHIP_TYPES }
  validates :passage_id, uniqueness: { scope: :parallel_passage_id }
end
