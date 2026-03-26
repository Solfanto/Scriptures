require "test_helper"

class PassageTest < ActiveSupport::TestCase
  test "text_for returns the text of a given translation" do
    passage = passages(:genesis_one_one)
    assert_equal "In the beginning God created the heaven and the earth.", passage.text_for(translations(:kjv))
  end

  test "text_for returns nil for missing translation" do
    passage = passages(:genesis_one_three)
    assert_nil passage.text_for(translations(:wlc))
  end

  test "delegates scripture to division" do
    assert_equal scriptures(:genesis), passages(:genesis_one_one).scripture
  end

  test "has many original language tokens" do
    assert_equal 3, passages(:genesis_one_one).original_language_tokens.count
  end

  test "has many textual variants" do
    assert_includes passages(:genesis_one_one).textual_variants, textual_variants(:genesis_one_one_sinaiticus)
  end
end
