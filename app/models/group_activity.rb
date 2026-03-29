class GroupActivity < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :action, presence: true
  validates :trackable_type, presence: true
  validates :trackable_id, presence: true

  default_scope { order(created_at: :desc) }

  def trackable
    trackable_type.constantize.find_by(id: trackable_id)
  end
end
