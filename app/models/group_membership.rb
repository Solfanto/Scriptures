# == Schema Information
#
# Table name: group_memberships
#
#  id         :bigint           not null, primary key
#  role       :string           default("viewer"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_group_memberships_on_group_id              (group_id)
#  index_group_memberships_on_group_id_and_user_id  (group_id,user_id) UNIQUE
#  index_group_memberships_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (user_id => users.id)
#
class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :role, presence: true, inclusion: { in: Group::ROLES }
  validates :user_id, uniqueness: { scope: :group_id }
end
