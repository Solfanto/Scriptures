require "test_helper"

class TraditionTest < ActiveSupport::TestCase
  test "requires name" do
    tradition = Tradition.new(slug: "test")
    assert_not tradition.valid?
    assert_includes tradition.errors[:name], "can't be blank"
  end

  test "requires unique slug" do
    tradition = Tradition.new(name: "Jewish", slug: "jewish")
    assert_not tradition.valid?
    assert_includes tradition.errors[:slug], "has already been taken"
  end

  test "to_param returns slug" do
    assert_equal "jewish", traditions(:jewish).to_param
  end

  test "has many corpora" do
    assert_includes traditions(:jewish).corpora, corpora(:bible)
  end
end
