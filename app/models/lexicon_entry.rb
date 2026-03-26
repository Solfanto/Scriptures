class LexiconEntry < ApplicationRecord
  has_many :original_language_tokens, dependent: :nullify

  validates :lemma, presence: true
  validates :language, presence: true
  validates :strongs_number, uniqueness: true, allow_nil: true
end
