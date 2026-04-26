# == Schema Information
#
# Table name: lexicon_entries
# Database name: primary
#
#  id               :bigint           not null, primary key
#  definition       :text
#  language         :string           not null
#  lemma            :string           not null
#  morphology_label :string
#  strongs_number   :string
#  transliteration  :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_lexicon_entries_on_lemma_and_language  (lemma,language)
#  index_lexicon_entries_on_strongs_number      (strongs_number) UNIQUE
#
class LexiconEntry < ApplicationRecord
  has_many :original_language_tokens, dependent: :nullify

  validates :lemma, presence: true
  validates :language, presence: true
  validates :strongs_number, uniqueness: true, allow_nil: true
end
