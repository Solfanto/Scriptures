class MagicToken < ApplicationRecord
  LIFETIME = 15.minutes
  SHORT_CODE_LENGTH = 6
  SHORT_CODE_CHARS = ("A".."Z").to_a + ("0".."9").to_a

  belongs_to :user

  before_create :set_token_and_expiry

  scope :valid, -> { where("expires_at > ?", Time.current) }

  def expired?
    expires_at <= Time.current
  end

  def self.generate_for(email_address, browser_token:)
    user = User.find_or_create_by!(email_address: email_address)
    user.magic_tokens.create!(browser_token: browser_token)
  end

  def self.find_and_consume!(token)
    magic_token = valid.find_by!(token: token)
    user = magic_token.user
    magic_token.destroy!
    user
  end

  def self.find_and_consume_by_code!(short_code, browser_token:)
    magic_token = valid.find_by!(short_code: short_code.upcase, browser_token: browser_token)
    user = magic_token.user
    magic_token.destroy!
    user
  end

  private

  def set_token_and_expiry
    self.token = SecureRandom.urlsafe_base64(32)
    self.short_code = generate_short_code
    self.expires_at = LIFETIME.from_now
  end

  def generate_short_code
    loop do
      code = Array.new(SHORT_CODE_LENGTH) { SHORT_CODE_CHARS.sample }.join
      break code unless MagicToken.valid.exists?(short_code: code)
    end
  end
end
