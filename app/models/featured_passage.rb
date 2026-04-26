# == Schema Information
#
# Table name: featured_passages
# Database name: primary
#
#  id           :bigint           not null, primary key
#  active_from  :date             not null
#  active_until :date
#  context      :text             not null
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  passage_id   :bigint           not null
#
# Indexes
#
#  index_featured_passages_on_active_from  (active_from)
#  index_featured_passages_on_passage_id   (passage_id)
#
# Foreign Keys
#
#  fk_rails_...  (passage_id => passages.id)
#
class FeaturedPassage < ApplicationRecord
  belongs_to :passage

  validates :title, :context, :active_from, presence: true

  scope :current, -> { where("active_from <= ? AND (active_until IS NULL OR active_until >= ?)", Date.current, Date.current) }

  def self.current_featured
    current.order(active_from: :desc).first
  end
end
