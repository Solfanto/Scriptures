require "test_helper"

class LexiconEntryTest < ActiveSupport::TestCase
  test "requires lemma" do
    entry = LexiconEntry.new(language: "Hebrew")
    assert_not entry.valid?
    assert_includes entry.errors[:lemma], "can't be blank"
  end

  test "requires language" do
    entry = LexiconEntry.new(lemma: "test")
    assert_not entry.valid?
    assert_includes entry.errors[:language], "can't be blank"
  end

  test "strongs_number must be unique" do
    entry = LexiconEntry.new(lemma: "test", language: "Hebrew", strongs_number: "H7225")
    assert_not entry.valid?
    assert_includes entry.errors[:strongs_number], "has already been taken"
  end

  test "strongs_number can be nil" do
    entry = LexiconEntry.new(lemma: "test", language: "Hebrew", strongs_number: nil)
    assert entry.valid?
  end

  test "has many original language tokens" do
    assert_includes lexicon_entries(:bereshit).original_language_tokens, original_language_tokens(:bereshit_token)
  end
end
