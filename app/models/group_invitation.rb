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
