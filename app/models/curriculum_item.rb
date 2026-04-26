# == Schema Information
#
# Table name: curriculum_items
# Database name: primary
#
#  id            :bigint           not null, primary key
#  notes         :text
#  position      :integer          not null
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  curriculum_id :bigint           not null
#  passage_id    :bigint           not null
#
# Indexes
#
#  index_curriculum_items_on_curriculum_id                 (curriculum_id)
#  index_curriculum_items_on_curriculum_id_and_passage_id  (curriculum_id,passage_id) UNIQUE
#  index_curriculum_items_on_passage_id                    (passage_id)
#
# Foreign Keys
#
#  fk_rails_...  (curriculum_id => curricula.id)
#  fk_rails_...  (passage_id => passages.id)
#
class CurriculumItem < ApplicationRecord
  belongs_to :curriculum, foreign_key: :curriculum_id
  belongs_to :passage

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :passage_id, uniqueness: { scope: :curriculum_id }

  default_scope { order(:position) }

  delegate :division, :scripture, to: :passage
  delegate :corpus, to: :scripture
end
