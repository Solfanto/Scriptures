# == Schema Information
#
# Table name: passkey_credentials
# Database name: primary
#
#  id          :bigint           not null, primary key
#  label       :string
#  public_key  :text             not null
#  sign_count  :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :string           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_passkey_credentials_on_external_id  (external_id) UNIQUE
#  index_passkey_credentials_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PasskeyCredential < ApplicationRecord
  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true
end
