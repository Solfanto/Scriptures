require "test_helper"

class Groups::MembershipsControllerTest < ActionDispatch::IntegrationTest
  test "destroy lets member leave" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    other = User.create!(email: "member@example.com")
    group.group_memberships.create!(user: other, role: "viewer")
    sign_in_as(other)

    delete group_membership_path(group)
    assert_redirected_to groups_path
    assert_not group.member?(other)
  end

  test "destroy lets owner remove member" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    other = User.create!(email: "member@example.com")
    group.group_memberships.create!(user: users(:scholar), role: "owner")
    group.group_memberships.create!(user: other, role: "viewer")
    sign_in_as(users(:scholar))

    delete group_membership_path(group, user_id: other.id)
    assert_redirected_to group_path(group)
    assert_not group.reload.group_memberships.exists?(user: other)
  end

  test "destroy prevents owner from leaving" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    group.group_memberships.create!(user: users(:scholar), role: "owner")
    sign_in_as(users(:scholar))

    delete group_membership_path(group)
    assert_redirected_to group_path(group)
    assert group.member?(users(:scholar))
  end
end
