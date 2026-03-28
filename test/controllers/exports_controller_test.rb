require "test_helper"

class ExportsControllerTest < ActionDispatch::IntegrationTest
  test "passages PDF export renders" do
    get export_passages_path(
      corpus_slug: "bible",
      scripture_slug: "genesis",
      format: :pdf,
      from_chapter: 1,
      t: ["KJV"]
    )
    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF")
  end

  test "passages PDF with options" do
    sign_in_as(users(:scholar))
    get export_passages_path(
      corpus_slug: "bible",
      scripture_slug: "genesis",
      format: :pdf,
      from_chapter: 1,
      to_chapter: 1,
      t: ["KJV", "WLC"],
      parallel: "1",
      sources: "1",
      commentary: "1",
      annotations: "1"
    )
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "collection PDF export renders" do
    sign_in_as(users(:scholar))
    collection = users(:scholar).collections.create!(name: "Test PDF", public: true)
    collection.collection_passages.create!(passage: passages(:genesis_one_one), position: 1)

    get export_collection_path(collection, format: :pdf)
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "collection PDF rejects private collection without auth" do
    sign_in_as(users(:scholar))
    collection = users(:scholar).collections.create!(name: "Private", public: false)
    sign_out

    get export_collection_path(collection, format: :pdf)
    assert_redirected_to root_path
  end

  test "public collection PDF works without auth" do
    collection = users(:scholar).collections.create!(name: "Public", public: true)
    collection.collection_passages.create!(passage: passages(:genesis_one_one), position: 1)

    get export_collection_path(collection, format: :pdf)
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end
end
