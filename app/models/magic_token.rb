class MagicToken < ApplicationRecord
  LIFETIME = 15.minutes

  belongs_to :user

  before_create :set_token_and_expiry

  scope :valid, -> { where("expires_at > ?", Time.current) }

  def expired?
    expires_at <= Time.current
  end

  def self.generate_for(email_address)
    user = User.find_or_create_by!(email_address: email_address)
    user.magic_tokens.create!
  end

  def self.find_and_consume!(token)
    magic_token = valid.find_by!(token: token)
    user = magic_token.user
    magic_token.destroy!
    user
  end

  private

  def set_token_and_expiry
    self.token = SecureRandom.urlsafe_base64(32)
    self.expires_at = LIFETIME.from_now
  end
end
