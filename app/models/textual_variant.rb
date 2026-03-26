class TextualVariant < ApplicationRecord
  belongs_to :passage
  belongs_to :manuscript

  validates :text, presence: true
  validates :passage_id, uniqueness: { scope: :manuscript_id }
end
