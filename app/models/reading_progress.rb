# == Schema Information
#
# Table name: reading_progresses
#
#  id                 :bigint           not null, primary key
#  read_at            :datetime         not null
#  time_spent_seconds :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  passage_id         :bigint           not null
#  user_id            :bigint           not null
#
# Indexes
#
#  index_reading_progresses_on_passage_id              (passage_id)
#  index_reading_progresses_on_user_id                 (user_id)
#  index_reading_progresses_on_user_id_and_passage_id  (user_id,passage_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (passage_id => passages.id)
#  fk_rails_...  (user_id => users.id)
#
class ReadingProgress < ApplicationRecord
  belongs_to :user
  belongs_to :passage

  validates :read_at, presence: true
  validates :passage_id, uniqueness: { scope: :user_id }
end
