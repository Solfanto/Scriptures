require "test_helper"

class OriginalLanguageTokenTest < ActiveSupport::TestCase
  test "requires text" do
    token = OriginalLanguageToken.new(passage: passages(:genesis_one_one), position: 99)
    assert_not token.valid?
    assert_includes token.errors[:text], "can't be blank"
  end

  test "requires position" do
    token = OriginalLanguageToken.new(passage: passages(:genesis_one_one), text: "test")
    assert_not token.valid?
    assert_includes token.errors[:position], "can't be blank"
  end

  test "position must be unique within passage" do
    token = OriginalLanguageToken.new(passage: passages(:genesis_one_one), text: "dup", position: 1)
    assert_not token.valid?
    assert_includes token.errors[:position], "has already been taken"
  end

  test "lexicon_entry is optional" do
    token = OriginalLanguageToken.new(passage: passages(:genesis_one_two), text: "test", position: 1)
    assert token.valid?
  end

  test "ordered by position" do
    tokens = passages(:genesis_one_one).original_language_tokens
    assert_equal [ 1, 2, 3 ], tokens.map(&:position)
  end
end
