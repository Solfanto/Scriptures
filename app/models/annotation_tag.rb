# == Schema Information
#
# Table name: annotation_tags
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  annotation_id :bigint           not null
#  tag_id        :bigint           not null
#
# Indexes
#
#  index_annotation_tags_on_annotation_id             (annotation_id)
#  index_annotation_tags_on_annotation_id_and_tag_id  (annotation_id,tag_id) UNIQUE
#  index_annotation_tags_on_tag_id                    (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (annotation_id => annotations.id)
#  fk_rails_...  (tag_id => tags.id)
#
class AnnotationTag < ApplicationRecord
  belongs_to :annotation
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :annotation_id }
end
