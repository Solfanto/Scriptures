require "test_helper"

class ManuscriptTest < ActiveSupport::TestCase
  test "requires name" do
    ms = Manuscript.new(abbreviation: "X", corpus: corpora(:bible))
    assert_not ms.valid?
    assert_includes ms.errors[:name], "can't be blank"
  end

  test "requires abbreviation" do
    ms = Manuscript.new(name: "Test", corpus: corpora(:bible))
    assert_not ms.valid?
    assert_includes ms.errors[:abbreviation], "can't be blank"
  end

  test "abbreviation must be unique within corpus" do
    ms = Manuscript.new(name: "Duplicate", abbreviation: "01", corpus: corpora(:bible))
    assert_not ms.valid?
    assert_includes ms.errors[:abbreviation], "has already been taken"
  end

  test "same abbreviation allowed in different corpus" do
    ms = Manuscript.new(name: "Other", abbreviation: "01", corpus: corpora(:new_testament))
    assert ms.valid?
  end

  test "has many textual variants" do
    assert_includes manuscripts(:sinaiticus).textual_variants, textual_variants(:genesis_one_one_sinaiticus)
  end
end
