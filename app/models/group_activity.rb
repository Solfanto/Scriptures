# == Schema Information
#
# Table name: group_activities
#
#  id             :bigint           not null, primary key
#  action         :string           not null
#  trackable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_id       :bigint           not null
#  trackable_id   :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_group_activities_on_group_id                         (group_id)
#  index_group_activities_on_group_id_and_created_at          (group_id,created_at)
#  index_group_activities_on_trackable_type_and_trackable_id  (trackable_type,trackable_id)
#  index_group_activities_on_user_id                          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (user_id => users.id)
#
class GroupActivity < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :action, presence: true
  validates :trackable_type, presence: true
  validates :trackable_id, presence: true

  default_scope { order(created_at: :desc) }

  def trackable
    trackable_type.constantize.find_by(id: trackable_id)
  end
end
