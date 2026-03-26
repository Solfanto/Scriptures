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
