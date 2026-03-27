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
