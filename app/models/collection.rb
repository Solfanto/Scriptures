class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :group, optional: true
  has_many :collection_passages, dependent: :destroy
  has_many :passages, through: :collection_passages

  validates :name, presence: true

  scope :publicly_visible, -> { where(public: true) }

  default_scope { order(updated_at: :desc) }
end
