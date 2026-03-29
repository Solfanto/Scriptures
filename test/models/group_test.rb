require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "valid group" do
    group = Group.new(name: "Seminar", owner: users(:scholar))
    assert group.valid?
  end

  test "requires name" do
    group = Group.new(name: "", owner: users(:scholar))
    assert_not group.valid?
  end

  test "role_for returns owner for group owner" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    assert_equal "owner", group.role_for(users(:scholar))
  end

  test "role_for returns membership role" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    other = User.create!(email: "other@example.com")
    group.group_memberships.create!(user: other, role: "editor")
    assert_equal "editor", group.role_for(other)
  end

  test "editor? returns true for owner" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    assert group.editor?(users(:scholar))
  end

  test "member? returns true for owner" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    assert group.member?(users(:scholar))
  end

  test "record_activity! creates activity" do
    group = Group.create!(name: "Test", owner: users(:scholar))
    group.group_memberships.create!(user: users(:scholar), role: "owner")
    collection = group.collections.create!(name: "Shared", user: users(:scholar))

    assert_difference "GroupActivity.count", 1 do
      group.record_activity!(user: users(:scholar), action: "created", trackable: collection)
    end
  end
end
