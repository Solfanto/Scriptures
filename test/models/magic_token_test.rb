require "test_helper"

class MagicTokenTest < ActiveSupport::TestCase
  test "generate_for creates user and token" do
    token = MagicToken.generate_for("new@example.com")
    assert token.persisted?
    assert token.token.present?
    assert token.expires_at > Time.current
    assert_equal "new@example.com", token.user.email_address
  end

  test "generate_for reuses existing user" do
    existing = users(:scholar)
    token = MagicToken.generate_for(existing.email_address)
    assert_equal existing, token.user
  end

  test "find_and_consume! returns user and destroys token" do
    token = magic_tokens(:valid_token)
    user = MagicToken.find_and_consume!(token.token)
    assert_equal users(:scholar), user
    assert_nil MagicToken.find_by(id: token.id)
  end

  test "find_and_consume! raises for expired token" do
    token = magic_tokens(:expired_token)
    assert_raises(ActiveRecord::RecordNotFound) do
      MagicToken.find_and_consume!(token.token)
    end
  end

  test "find_and_consume! raises for unknown token" do
    assert_raises(ActiveRecord::RecordNotFound) do
      MagicToken.find_and_consume!("nonexistent")
    end
  end

  test "expired? returns true for past expiry" do
    assert magic_tokens(:expired_token).expired?
  end

  test "expired? returns false for future expiry" do
    assert_not magic_tokens(:valid_token).expired?
  end
end
