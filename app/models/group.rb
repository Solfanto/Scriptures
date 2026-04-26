# == Schema Information
#
# Table name: groups
# Database name: primary
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  public      :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :bigint           not null
#
# Indexes
#
#  index_groups_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
class Group < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user
  has_many :group_invitations, dependent: :destroy
  has_many :group_activities, dependent: :destroy
  has_many :annotations, dependent: :nullify
  has_many :collections, dependent: :nullify
  has_many :curricula, class_name: "Curriculum", dependent: :nullify

  validates :name, presence: true

  scope :publicly_visible, -> { where(public: true) }

  default_scope { order(updated_at: :desc) }

  ROLES = %w[owner editor viewer].freeze

  def role_for(user)
    return "owner" if owner == user
    group_memberships.find_by(user: user)&.role
  end

  def editor?(user)
    role_for(user).in?(%w[owner editor])
  end

  def member?(user)
    owner == user || group_memberships.exists?(user: user)
  end

  def record_activity!(user:, action:, trackable:)
    group_activities.create!(user: user, action: action, trackable_type: trackable.class.name, trackable_id: trackable.id)
  end
end
