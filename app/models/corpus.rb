# == Schema Information
#
# Table name: corpora
#
#  id           :bigint           not null, primary key
#  description  :text
#  name         :string           not null
#  slug         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  tradition_id :bigint           not null
#
# Indexes
#
#  index_corpora_on_slug          (slug) UNIQUE
#  index_corpora_on_tradition_id  (tradition_id)
#
# Foreign Keys
#
#  fk_rails_...  (tradition_id => traditions.id)
#
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
