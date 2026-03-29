class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :role, presence: true, inclusion: { in: Group::ROLES }
  validates :user_id, uniqueness: { scope: :group_id }
end
