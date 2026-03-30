# == Schema Information
#
# Table name: composition_dates
#
#  id            :bigint           not null, primary key
#  citation      :text
#  confidence    :string
#  description   :text
#  earliest_year :integer
#  latest_year   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  scripture_id  :bigint           not null
#
# Indexes
#
#  index_composition_dates_on_scripture_id  (scripture_id)
#
# Foreign Keys
#
#  fk_rails_...  (scripture_id => scriptures.id)
#
class CompositionDate < ApplicationRecord
  belongs_to :scripture

  validates :confidence, inclusion: { in: %w[high medium low speculative], allow_nil: true }

  def date_range
    [ earliest_year, latest_year ].compact.uniq.join("–")
  end

  def bce?
    earliest_year&.negative? || latest_year&.negative?
  end
end
