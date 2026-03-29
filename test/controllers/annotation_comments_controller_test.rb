require "test_helper"

class AnnotationCommentsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:scholar)) }

  test "create adds comment to group annotation" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    group.group_memberships.create!(user: users(:scholar), role: "owner")
    annotation = users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "Group note", group: group)

    assert_difference "AnnotationComment.count", 1 do
      post annotation_comments_path(annotation_id: annotation.id, body: "Great point")
    end
  end

  test "create rejects non-member" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    annotation = users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "Note", group: group)
    other = User.create!(email: "outsider@example.com")
    sign_in_as(other)

    assert_no_difference "AnnotationComment.count" do
      post annotation_comments_path(annotation_id: annotation.id, body: "Spam")
    end
    assert_redirected_to root_path
  end

  test "destroy removes own comment" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    group.group_memberships.create!(user: users(:scholar), role: "owner")
    annotation = users(:scholar).annotations.create!(passage: passages(:genesis_one_one), body: "Note", group: group)
    comment = annotation.annotation_comments.create!(user: users(:scholar), body: "My comment")

    assert_difference "AnnotationComment.count", -1 do
      delete annotation_comment_path(comment)
    end
  end
end
