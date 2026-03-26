class OriginalLanguageToken < ApplicationRecord
  belongs_to :passage
  belongs_to :lexicon_entry, optional: true

  validates :text, presence: true
  validates :position, presence: true, uniqueness: { scope: :passage_id }

  default_scope { order(:position) }
end
