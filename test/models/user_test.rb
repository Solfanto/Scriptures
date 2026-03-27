require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires email_address" do
    user = User.new(email_address: nil)
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "requires unique email_address" do
    user = User.new(email_address: "scholar@example.com")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "validates email format" do
    user = User.new(email_address: "not-an-email")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "password is optional" do
    user = User.new(email_address: "new@example.com")
    assert user.valid?
  end
end
