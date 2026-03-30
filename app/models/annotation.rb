# == Schema Information
#
# Table name: annotations
#
#  id         :bigint           not null, primary key
#  body       :text             not null
#  public     :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint
#  passage_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_annotations_on_group_id                (group_id)
#  index_annotations_on_passage_id              (passage_id)
#  index_annotations_on_user_id                 (user_id)
#  index_annotations_on_user_id_and_passage_id  (user_id,passage_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (passage_id => passages.id)
#  fk_rails_...  (user_id => users.id)
#
class Annotation < ApplicationRecord
  belongs_to :user
  belongs_to :passage
  belongs_to :group, optional: true
  has_many :annotation_tags, dependent: :destroy
  has_many :tags, through: :annotation_tags
  has_many :annotation_comments, dependent: :destroy

  validates :body, presence: true

  scope :publicly_visible, -> { where(public: true) }

  default_scope { order(created_at: :desc) }

  delegate :division, to: :passage
  delegate :scripture, to: :division

  def tag_list
    tags.pluck(:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.split(",").map(&:strip).reject(&:blank?).map do |name|
      Tag.find_or_create_by!(user: user, name: name)
    end
  end
end
