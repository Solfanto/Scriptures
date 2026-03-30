# == Schema Information
#
# Table name: passage_translations
#
#  id             :bigint           not null, primary key
#  search_vector  :tsvector
#  text           :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  passage_id     :bigint           not null
#  translation_id :bigint           not null
#
# Indexes
#
#  index_passage_translations_on_passage_id                     (passage_id)
#  index_passage_translations_on_passage_id_and_translation_id  (passage_id,translation_id) UNIQUE
#  index_passage_translations_on_search_vector                  (search_vector) USING gin
#  index_passage_translations_on_translation_id                 (translation_id)
#
# Foreign Keys
#
#  fk_rails_...  (passage_id => passages.id)
#  fk_rails_...  (translation_id => translations.id)
#
class PassageTranslation < ApplicationRecord
  belongs_to :passage
  belongs_to :translation
  has_many :ratings, dependent: :destroy

  validates :text, presence: true
  validates :passage_id, uniqueness: { scope: :translation_id }
end
