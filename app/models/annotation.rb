class Annotation < ApplicationRecord
  belongs_to :user
  belongs_to :passage
  has_many :annotation_tags, dependent: :destroy
  has_many :tags, through: :annotation_tags

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
