require "test_helper"

class CorpusTest < ActiveSupport::TestCase
  test "requires name" do
    corpus = Corpus.new(slug: "test", tradition: traditions(:jewish))
    assert_not corpus.valid?
    assert_includes corpus.errors[:name], "can't be blank"
  end

  test "requires unique slug" do
    corpus = Corpus.new(name: "Bible", slug: "bible", tradition: traditions(:jewish))
    assert_not corpus.valid?
    assert_includes corpus.errors[:slug], "has already been taken"
  end

  test "to_param returns slug" do
    assert_equal "bible", corpora(:bible).to_param
  end

  test "has many scriptures" do
    assert_includes corpora(:bible).scriptures, scriptures(:genesis)
  end

  test "has many manuscripts" do
    assert_includes corpora(:bible).manuscripts, manuscripts(:sinaiticus)
  end
end
