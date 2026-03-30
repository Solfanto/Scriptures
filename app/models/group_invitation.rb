# == Schema Information
#
# Table name: group_invitations
#
#  id            :bigint           not null, primary key
#  accepted_at   :datetime
#  email         :string           not null
#  role          :string           default("viewer"), not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  group_id      :bigint           not null
#  invited_by_id :bigint           not null
#
# Indexes
#
#  index_group_invitations_on_email          (email)
#  index_group_invitations_on_group_id       (group_id)
#  index_group_invitations_on_invited_by_id  (invited_by_id)
#  index_group_invitations_on_token          (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (invited_by_id => users.id)
#
class GroupInvitation < ApplicationRecord
  belongs_to :group
  belongs_to :invited_by, class_name: "User"

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[editor viewer] }
  validates :token, presence: true, uniqueness: true

  before_validation :set_token, on: :create

  scope :pending, -> { where(accepted_at: nil) }

  def accepted?
    accepted_at.present?
  end

  def accept!(user)
    transaction do
      update!(accepted_at: Time.current)
      group.group_memberships.find_or_create_by!(user: user) do |m|
        m.role = role
      end
    end
  end

  private

  def set_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end
end
