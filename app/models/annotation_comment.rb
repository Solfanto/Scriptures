# == Schema Information
#
# Table name: annotation_comments
# Database name: primary
#
#  id            :bigint           not null, primary key
#  body          :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  annotation_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_annotation_comments_on_annotation_id  (annotation_id)
#  index_annotation_comments_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (annotation_id => annotations.id)
#  fk_rails_...  (user_id => users.id)
#
class AnnotationComment < ApplicationRecord
  belongs_to :annotation
  belongs_to :user

  validates :body, presence: true

  default_scope { order(:created_at) }
end
