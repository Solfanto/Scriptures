# == Schema Information
#
# Table name: source_documents
# Database name: primary
#
#  id               :bigint           not null, primary key
#  abbreviation     :string
#  bibliography_url :string
#  color            :string
#  description      :text
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  corpus_id        :bigint           not null
#
# Indexes
#
#  index_source_documents_on_abbreviation  (abbreviation)
#  index_source_documents_on_corpus_id     (corpus_id)
#
# Foreign Keys
#
#  fk_rails_...  (corpus_id => corpora.id)
#
class SourceDocument < ApplicationRecord
  belongs_to :corpus
  has_many :passage_source_documents, dependent: :destroy
  has_many :passages, through: :passage_source_documents

  validates :name, presence: true
  validates :abbreviation, presence: true
end
