class Corpus < ApplicationRecord
  self.table_name = "corpora"

  belongs_to :tradition
  has_many :scriptures, dependent: :destroy
  has_many :translations, dependent: :destroy
  has_many :source_documents, dependent: :destroy
  has_many :manuscripts, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def to_param = slug
end
