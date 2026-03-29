require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:scholar)) }

  test "index lists groups" do
    Group.create!(name: "My Seminar", owner: users(:scholar)).tap do |g|
      g.group_memberships.create!(user: users(:scholar), role: "owner")
    end
    get groups_path
    assert_response :success
    assert_select "div", /My Seminar/
  end

  test "new renders form" do
    get new_group_path
    assert_response :success
    assert_select "form"
  end

  test "create makes a new group with owner membership" do
    assert_difference [ "Group.count", "GroupMembership.count" ], 1 do
      post groups_path, params: { group: { name: "Research Team" } }
    end
    group = Group.last
    assert_equal users(:scholar), group.owner
    assert_equal "owner", group.group_memberships.find_by(user: users(:scholar)).role
  end

  test "show renders group" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    group.group_memberships.create!(user: users(:scholar), role: "owner")
    get group_path(group)
    assert_response :success
  end

  test "show renders public group without auth" do
    group = Group.create!(name: "Public", owner: users(:scholar), public: true)
    sign_out
    get group_path(group)
    assert_response :success
  end

  test "show rejects private group without membership" do
    group = Group.create!(name: "Private", owner: users(:scholar))
    other = User.create!(email: "other@example.com")
    sign_in_as(other)
    get group_path(group)
    assert_redirected_to root_path
  end

  test "invite sends email" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    group.group_memberships.create!(user: users(:scholar), role: "owner")
    assert_enqueued_emails 1 do
      post group_invitations_path(group), params: { email: "invitee@example.com", role: "editor" }
    end
    assert_redirected_to group_path(group)
  end

  test "accept_invitation joins group" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    inv = group.group_invitations.create!(email: "scholar@example.com", invited_by: users(:scholar), role: "viewer")
    get group_invitation_accept_path(token: inv.token)
    assert_redirected_to group_path(group)
    assert group.member?(users(:scholar))
  end

  test "leave removes membership" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    other = User.create!(email: "member@example.com")
    group.group_memberships.create!(user: other, role: "viewer")
    sign_in_as(other)
    delete group_membership_path(group)
    assert_redirected_to groups_path
    assert_not group.member?(other)
  end

  test "destroy deletes group" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    assert_difference "Group.count", -1 do
      delete group_path(group)
    end
  end
end
