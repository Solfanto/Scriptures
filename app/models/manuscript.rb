class Manuscript < ApplicationRecord
  belongs_to :corpus
  has_many :textual_variants, dependent: :destroy

  validates :name, presence: true
  validates :abbreviation, presence: true, uniqueness: { scope: :corpus_id }
end
