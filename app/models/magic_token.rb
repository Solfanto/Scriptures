# == Schema Information
#
# Table name: magic_tokens
#
#  id            :bigint           not null, primary key
#  browser_token :string           default(""), not null
#  expires_at    :datetime         not null
#  short_code    :string           default(""), not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_magic_tokens_on_browser_token  (browser_token)
#  index_magic_tokens_on_short_code     (short_code)
#  index_magic_tokens_on_token          (token) UNIQUE
#  index_magic_tokens_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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

  def self.generate_for(email, browser_token:)
    user = User.find_or_create_by!(email: email)
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
