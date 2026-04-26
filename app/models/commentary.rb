# == Schema Information
#
# Table name: commentaries
# Database name: primary
#
#  id              :bigint           not null, primary key
#  author          :string           not null
#  body            :text             not null
#  commentary_type :string           not null
#  source          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  passage_id      :bigint           not null
#
# Indexes
#
#  index_commentaries_on_passage_id                      (passage_id)
#  index_commentaries_on_passage_id_and_commentary_type  (passage_id,commentary_type)
#
# Foreign Keys
#
#  fk_rails_...  (passage_id => passages.id)
#
class Commentary < ApplicationRecord
  TYPES = %w[critical historical devotional].freeze

  belongs_to :passage

  validates :author, presence: true
  validates :body, presence: true
  validates :commentary_type, presence: true, inclusion: { in: TYPES }

  scope :critical, -> { where(commentary_type: "critical") }
  scope :historical, -> { where(commentary_type: "historical") }
end
