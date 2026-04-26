# == Schema Information
#
# Table name: textual_variants
# Database name: primary
#
#  id            :bigint           not null, primary key
#  notes         :text
#  text          :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  manuscript_id :bigint           not null
#  passage_id    :bigint           not null
#
# Indexes
#
#  index_textual_variants_on_manuscript_id                 (manuscript_id)
#  index_textual_variants_on_passage_id                    (passage_id)
#  index_textual_variants_on_passage_id_and_manuscript_id  (passage_id,manuscript_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (manuscript_id => manuscripts.id)
#  fk_rails_...  (passage_id => passages.id)
#
class TextualVariant < ApplicationRecord
  belongs_to :passage
  belongs_to :manuscript

  validates :text, presence: true
  validates :passage_id, uniqueness: { scope: :manuscript_id }
end
