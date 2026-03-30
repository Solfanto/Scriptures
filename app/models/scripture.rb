# == Schema Information
#
# Table name: scriptures
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  position    :integer
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  corpus_id   :bigint           not null
#
# Indexes
#
#  index_scriptures_on_corpus_id           (corpus_id)
#  index_scriptures_on_corpus_id_and_slug  (corpus_id,slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (corpus_id => corpora.id)
#
class Scripture < ApplicationRecord
  belongs_to :corpus
  has_many :divisions, dependent: :destroy
  has_many :composition_dates, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :corpus_id }

  default_scope { order(:position) }

  def to_param = slug
end
