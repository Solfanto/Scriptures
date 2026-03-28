require "test_helper"

class AnnotationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:scholar)) }

  test "create saves annotation with tags" do
    assert_difference "Annotation.count", 1 do
      post annotations_path, params: {
        annotation: {
          passage_id: passages(:genesis_one_one).id,
          body: "Interesting verse",
          tag_list: "creation, priestly"
        }
      }
    end
    annotation = Annotation.last
    assert_equal "Interesting verse", annotation.body
    assert_equal 2, annotation.tags.count
  end

  test "destroy removes annotation" do
    annotation = users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "test")
    assert_difference "Annotation.count", -1 do
      delete annotation_path(annotation)
    end
  end

  test "export JSON returns annotations" do
    users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "Export me")
    get export_annotations_path(format: :json)
    assert_response :success
    assert_equal "application/json", response.media_type
    data = JSON.parse(response.body)
    assert_equal 1, data.size
    assert_equal "Export me", data.first["body"]
    assert_equal "genesis", data.first["scripture"]
    assert_equal 1, data.first["chapter"]
    assert_equal 1, data.first["verse"]
  end

  test "export CSV returns annotations" do
    users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "Export CSV")
    get export_annotations_path(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_includes response.body, "Export CSV"
    assert_includes response.body, "Genesis 1:1"
  end

  test "import JSON creates annotations" do
    json = [
      {
        corpus: "bible",
        scripture: "genesis",
        chapter: 1,
        verse: 1,
        body: "Imported annotation",
        tags: ["imported"],
        public: false
      }
    ].to_json

    file = Rack::Test::UploadedFile.new(
      StringIO.new(json), "application/json", false, original_filename: "annotations.json"
    )

    assert_difference "Annotation.count", 1 do
      post import_annotations_path, params: { file: file }
    end
    assert_redirected_to annotations_path(user_id: users(:scholar))
    assert_equal "Imported annotation", Annotation.last.body
  end

  test "import JSON deduplicates" do
    users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "Already here")
    json = [{ corpus: "bible", scripture: "genesis", chapter: 1, verse: 1, body: "Already here" }].to_json

    file = Rack::Test::UploadedFile.new(
      StringIO.new(json), "application/json", false, original_filename: "annotations.json"
    )

    assert_no_difference "Annotation.count" do
      post import_annotations_path, params: { file: file }
    end
  end

  test "update toggles public flag" do
    annotation = users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "test")
    assert_not annotation.public?
    patch annotation_path(annotation), params: { annotation: { public: true } }
    assert annotation.reload.public?
  end

  test "public_set shows public annotations without auth" do
    users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "Public note", public: true)
    users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "Private note", public: false)
    sign_out
    get public_annotations_path(user_id: users(:scholar))
    assert_response :success
    assert_select "p", /Public note/
    assert_select "p", { text: /Private note/, count: 0 }
  end
end
