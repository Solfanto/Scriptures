# == Schema Information
#
# Table name: original_language_tokens
# Database name: primary
#
#  id               :bigint           not null, primary key
#  lemma            :string
#  morphology       :string
#  position         :integer          not null
#  text             :string           not null
#  transliteration  :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  lexicon_entry_id :bigint
#  passage_id       :bigint           not null
#
# Indexes
#
#  index_original_language_tokens_on_lemma                    (lemma)
#  index_original_language_tokens_on_lexicon_entry_id         (lexicon_entry_id)
#  index_original_language_tokens_on_passage_id               (passage_id)
#  index_original_language_tokens_on_passage_id_and_position  (passage_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (lexicon_entry_id => lexicon_entries.id)
#  fk_rails_...  (passage_id => passages.id)
#
class OriginalLanguageToken < ApplicationRecord
  belongs_to :passage
  belongs_to :lexicon_entry, optional: true

  validates :text, presence: true
  validates :position, presence: true, uniqueness: { scope: :passage_id }

  default_scope { order(:position) }
end
