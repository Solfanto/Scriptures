class Passage < ApplicationRecord
  belongs_to :division
  has_many :passage_translations, dependent: :destroy
  has_many :translations, through: :passage_translations
  has_many :passage_source_documents, dependent: :destroy
  has_many :source_documents, through: :passage_source_documents
  has_many :original_language_tokens, dependent: :destroy
  has_many :textual_variants, dependent: :destroy
  has_many :parallel_passages, dependent: :destroy

  default_scope { order(:position) }

  delegate :scripture, to: :division

  def text_for(translation)
    passage_translations.find_by(translation: translation)&.text
  end
end
