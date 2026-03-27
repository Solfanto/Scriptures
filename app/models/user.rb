class User < ApplicationRecord
  has_secure_password validations: false
  has_many :sessions, dependent: :destroy
  has_many :magic_tokens, dependent: :destroy
  has_many :passkey_credentials, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :highlights, dependent: :destroy
  has_many :annotations, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :parallel_passages, dependent: :nullify

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
