# == Schema Information
#
# Table name: passages
#
#  id          :bigint           not null, primary key
#  number      :integer
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  division_id :bigint           not null
#
# Indexes
#
#  index_passages_on_division_id             (division_id)
#  index_passages_on_division_id_and_number  (division_id,number)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#
class Passage < ApplicationRecord
  belongs_to :division
  has_many :passage_translations, dependent: :destroy
  has_many :translations, through: :passage_translations
  has_many :passage_source_documents, dependent: :destroy
  has_many :source_documents, through: :passage_source_documents
  has_many :original_language_tokens, dependent: :destroy
  has_many :textual_variants, dependent: :destroy
  has_many :parallel_passages, dependent: :destroy
  has_many :commentaries, dependent: :destroy
  has_many :curriculum_items, dependent: :destroy
  has_many :reading_progresses, dependent: :destroy

  default_scope { order(:position) }

  delegate :scripture, to: :division

  def text_for(translation)
    passage_translations.find_by(translation: translation)&.text
  end
end
