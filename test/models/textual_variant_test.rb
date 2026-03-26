require "test_helper"

class TextualVariantTest < ActiveSupport::TestCase
  test "requires text" do
    variant = TextualVariant.new(passage: passages(:genesis_one_two), manuscript: manuscripts(:sinaiticus))
    assert_not variant.valid?
    assert_includes variant.errors[:text], "can't be blank"
  end

  test "passage and manuscript combination must be unique" do
    variant = TextualVariant.new(
      passage: passages(:genesis_one_one),
      manuscript: manuscripts(:sinaiticus),
      text: "duplicate"
    )
    assert_not variant.valid?
    assert_includes variant.errors[:passage_id], "has already been taken"
  end
end
