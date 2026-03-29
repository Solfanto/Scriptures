class AnnotationComment < ApplicationRecord
  belongs_to :annotation
  belongs_to :user

  validates :body, presence: true

  default_scope { order(:created_at) }
end
