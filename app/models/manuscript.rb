# == Schema Information
#
# Table name: manuscripts
#
#  id               :bigint           not null, primary key
#  abbreviation     :string           not null
#  date_description :string
#  description      :text
#  facsimile_url    :string
#  language         :string
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  corpus_id        :bigint           not null
#
# Indexes
#
#  index_manuscripts_on_corpus_id                   (corpus_id)
#  index_manuscripts_on_corpus_id_and_abbreviation  (corpus_id,abbreviation) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (corpus_id => corpora.id)
#
class Manuscript < ApplicationRecord
  belongs_to :corpus
  has_many :textual_variants, dependent: :destroy

  validates :name, presence: true
  validates :abbreviation, presence: true, uniqueness: { scope: :corpus_id }
end
