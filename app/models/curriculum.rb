class Curriculum < ApplicationRecord
  self.table_name = "curricula"

  belongs_to :user
  belongs_to :group, optional: true
  has_many :curriculum_items, dependent: :destroy
  has_many :passages, through: :curriculum_items

  validates :name, presence: true

  scope :publicly_visible, -> { where(public: true) }

  default_scope { order(updated_at: :desc) }

  TYPES = %w[introduction source_criticism comparative thematic custom].freeze

  validates :curriculum_type, inclusion: { in: TYPES, allow_blank: true }

  def progress_for(user)
    return 0 if curriculum_items.none?
    read_ids = ReadingProgress.where(user: user, passage_id: passage_ids).pluck(:passage_id).to_set
    (read_ids.size.to_f / curriculum_items.size * 100).round
  end
end
