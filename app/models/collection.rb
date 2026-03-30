# == Schema Information
#
# Table name: collections
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  public      :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  group_id    :bigint
#  user_id     :bigint           not null
#
# Indexes
#
#  index_collections_on_group_id  (group_id)
#  index_collections_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (user_id => users.id)
#
class Collection < ApplicationRecord
  belongs_to :user
  belongs_to :group, optional: true
  has_many :collection_passages, dependent: :destroy
  has_many :passages, through: :collection_passages

  validates :name, presence: true

  scope :publicly_visible, -> { where(public: true) }

  default_scope { order(updated_at: :desc) }
end
