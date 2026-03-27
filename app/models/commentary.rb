class Commentary < ApplicationRecord
  TYPES = %w[critical historical devotional].freeze

  belongs_to :passage

  validates :author, presence: true
  validates :body, presence: true
  validates :commentary_type, presence: true, inclusion: { in: TYPES }

  scope :critical, -> { where(commentary_type: "critical") }
  scope :historical, -> { where(commentary_type: "historical") }
end
