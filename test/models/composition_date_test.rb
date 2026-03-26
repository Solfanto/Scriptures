require "test_helper"

class CompositionDateTest < ActiveSupport::TestCase
  test "confidence must be valid" do
    date = CompositionDate.new(scripture: scriptures(:genesis), confidence: "invalid")
    assert_not date.valid?
    assert_includes date.errors[:confidence], "is not included in the list"
  end

  test "confidence can be nil" do
    date = CompositionDate.new(scripture: scriptures(:genesis), confidence: nil)
    assert date.valid?
  end

  test "date_range formats year range" do
    assert_equal "-950–-450", composition_dates(:genesis_date).date_range
  end

  test "date_range with single year" do
    date = CompositionDate.new(earliest_year: 70, latest_year: 70)
    assert_equal "70", date.date_range
  end

  test "bce? returns true for negative years" do
    assert composition_dates(:genesis_date).bce?
  end

  test "bce? returns false for CE dates" do
    assert_not composition_dates(:mark_date).bce?
  end
end
