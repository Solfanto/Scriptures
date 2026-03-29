require "test_helper"

class GroupInvitationTest < ActiveSupport::TestCase
  test "generates token on create" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    inv = group.group_invitations.create!(email: "new@example.com", invited_by: users(:scholar), role: "viewer")
    assert inv.token.present?
  end

  test "accept! creates membership" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    inv = group.group_invitations.create!(email: "new@example.com", invited_by: users(:scholar), role: "editor")
    new_user = User.create!(email_address: "new@example.com")

    assert_difference "GroupMembership.count", 1 do
      inv.accept!(new_user)
    end
    assert inv.accepted?
    assert_equal "editor", group.group_memberships.find_by(user: new_user).role
  end
end
