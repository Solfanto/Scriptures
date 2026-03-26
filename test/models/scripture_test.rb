require "test_helper"

class ScriptureTest < ActiveSupport::TestCase
  test "requires name" do
    scripture = Scripture.new(slug: "test", corpus: corpora(:bible))
    assert_not scripture.valid?
    assert_includes scripture.errors[:name], "can't be blank"
  end

  test "slug must be unique within corpus" do
    scripture = Scripture.new(name: "Genesis", slug: "genesis", corpus: corpora(:bible))
    assert_not scripture.valid?
    assert_includes scripture.errors[:slug], "has already been taken"
  end

  test "same slug allowed in different corpus" do
    scripture = Scripture.new(name: "Genesis", slug: "genesis", corpus: corpora(:new_testament), position: 1)
    assert scripture.valid?
  end

  test "has many composition dates" do
    assert_includes scriptures(:genesis).composition_dates, composition_dates(:genesis_date)
  end
end
