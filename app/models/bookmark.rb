# == Schema Information
#
# Table name: bookmarks
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  passage_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_bookmarks_on_passage_id              (passage_id)
#  index_bookmarks_on_user_id                 (user_id)
#  index_bookmarks_on_user_id_and_passage_id  (user_id,passage_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (passage_id => passages.id)
#  fk_rails_...  (user_id => users.id)
#
class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :passage

  validates :passage_id, uniqueness: { scope: :user_id }

  default_scope { order(created_at: :desc) }

  delegate :division, to: :passage
  delegate :scripture, to: :division
end
