require "test_helper"

class ParallelPassageTest < ActiveSupport::TestCase
  test "requires relationship_type" do
    pp = ParallelPassage.new(
      passage: passages(:genesis_one_one),
      parallel_passage: passages(:genesis_one_two)
    )
    assert_not pp.valid?
    assert_includes pp.errors[:relationship_type], "can't be blank"
  end

  test "relationship_type must be from allowed list" do
    pp = ParallelPassage.new(
      passage: passages(:genesis_one_one),
      parallel_passage: passages(:genesis_one_two),
      relationship_type: "bogus"
    )
    assert_not pp.valid?
    assert_includes pp.errors[:relationship_type], "is not included in the list"
  end

  test "valid with allowed relationship type" do
    pp = ParallelPassage.new(
      passage: passages(:genesis_one_one),
      parallel_passage: passages(:genesis_one_two),
      relationship_type: "allusion"
    )
    assert pp.valid?
  end
end
