# == Schema Information
#
# Table name: ratings
# Database name: primary
#
#  id                     :bigint           not null, primary key
#  score                  :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  translation_segment_id :bigint           not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_ratings_on_translation_segment_id              (translation_segment_id)
#  index_ratings_on_user_id                             (user_id)
#  index_ratings_on_user_id_and_translation_segment_id  (user_id,translation_segment_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (translation_segment_id => translation_segments.id)
#  fk_rails_...  (user_id => users.id)
#
class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :translation_segment

  validates :score, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :translation_segment_id }
end
