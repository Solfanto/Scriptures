require "test_helper"

class MagicTokenTest < ActiveSupport::TestCase
  test "generate_for creates user and token with short_code and browser_token" do
    token = MagicToken.generate_for("new@example.com", browser_token: "bt_123")
    assert token.persisted?
    assert token.token.present?
    assert_equal 6, token.short_code.length
    assert_equal "bt_123", token.browser_token
    assert token.expires_at > Time.current
    assert_equal "new@example.com", token.user.email_address
  end

  test "generate_for reuses existing user" do
    existing = users(:scholar)
    token = MagicToken.generate_for(existing.email_address, browser_token: "bt")
    assert_equal existing, token.user
  end

  test "short_code is uppercase alphanumeric" do
    token = MagicToken.generate_for("new@example.com", browser_token: "bt")
    assert_match(/\A[A-Z0-9]{6}\z/, token.short_code)
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

  test "find_and_consume_by_code! returns user with matching browser_token" do
    token = magic_tokens(:valid_token)
    user = MagicToken.find_and_consume_by_code!(token.short_code, browser_token: token.browser_token)
    assert_equal users(:scholar), user
    assert_nil MagicToken.find_by(id: token.id)
  end

  test "find_and_consume_by_code! is case-insensitive" do
    token = magic_tokens(:valid_token)
    user = MagicToken.find_and_consume_by_code!(token.short_code.downcase, browser_token: token.browser_token)
    assert_equal users(:scholar), user
  end

  test "find_and_consume_by_code! rejects wrong browser_token" do
    token = magic_tokens(:valid_token)
    assert_raises(ActiveRecord::RecordNotFound) do
      MagicToken.find_and_consume_by_code!(token.short_code, browser_token: "wrong")
    end
  end

  test "find_and_consume_by_code! rejects expired code" do
    token = magic_tokens(:expired_token)
    assert_raises(ActiveRecord::RecordNotFound) do
      MagicToken.find_and_consume_by_code!(token.short_code, browser_token: token.browser_token)
    end
  end

  test "expired? returns true for past expiry" do
    assert magic_tokens(:expired_token).expired?
  end

  test "expired? returns false for future expiry" do
    assert_not magic_tokens(:valid_token).expired?
  end
end
