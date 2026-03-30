# == Schema Information
#
# Table name: ratings
#
#  id                     :bigint           not null, primary key
#  score                  :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  passage_translation_id :bigint           not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_ratings_on_passage_translation_id              (passage_translation_id)
#  index_ratings_on_user_id                             (user_id)
#  index_ratings_on_user_id_and_passage_translation_id  (user_id,passage_translation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (passage_translation_id => passage_translations.id)
#  fk_rails_...  (user_id => users.id)
#
class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :passage_translation

  validates :score, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :passage_translation_id }
end
