# == Schema Information
#
# Table name: divisions
# Database name: primary
#
#  id           :bigint           not null, primary key
#  name         :string
#  number       :integer
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  parent_id    :bigint
#  scripture_id :bigint           not null
#
# Indexes
#
#  index_divisions_on_parent_id                (parent_id)
#  index_divisions_on_scripture_id             (scripture_id)
#  index_divisions_on_scripture_id_and_number  (scripture_id,number)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => divisions.id)
#  fk_rails_...  (scripture_id => scriptures.id)
#
class Division < ApplicationRecord
  belongs_to :scripture
  belongs_to :parent, class_name: "Division", optional: true
  has_many :children, class_name: "Division", foreign_key: :parent_id, dependent: :destroy
  has_many :passages, dependent: :destroy

  default_scope { order(:position) }

  def display_name
    name || "Chapter #{number}"
  end
end
