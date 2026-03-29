require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new renders sign-in page" do
    get new_session_path
    assert_response :success
    assert_select "h1", "Sign in"
  end

  test "create sends magic link email and redirects to verify" do
    assert_enqueued_emails 1 do
      post session_path, params: { email_address: "scholar@example.com" }
    end
    assert_redirected_to verify_session_path
    assert cookies[:browser_token].present?
  end

  test "create auto-creates user for new email" do
    assert_difference "User.count", 1 do
      post session_path, params: { email_address: "brand-new@example.com" }
    end
  end

  test "verify renders code entry page" do
    get verify_session_path
    assert_response :success
    assert_select "h1", /Check your email/
  end

  test "verify_code signs in with valid code and browser_token" do
    token = magic_tokens(:valid_token)
    cookies[:browser_token] = create_signed_cookie(:browser_token, token.browser_token)
    post verify_code_session_path, params: { code: token.short_code }
    assert_redirected_to root_path
    assert cookies[:session_id].present?
  end

  test "verify_code is case-insensitive" do
    token = magic_tokens(:valid_token)
    cookies[:browser_token] = create_signed_cookie(:browser_token, token.browser_token)
    post verify_code_session_path, params: { code: token.short_code.downcase }
    assert_redirected_to root_path
    assert cookies[:session_id].present?
  end

  test "verify_code rejects wrong browser_token" do
    token = magic_tokens(:valid_token)
    cookies[:browser_token] = create_signed_cookie(:browser_token, "wrong_token")
    post verify_code_session_path, params: { code: token.short_code }
    assert_redirected_to verify_session_path
  end

  test "verify_code rejects missing browser_token" do
    token = magic_tokens(:valid_token)
    post verify_code_session_path, params: { code: token.short_code }
    assert_redirected_to new_session_path
  end

  test "verify_code rejects expired code" do
    token = magic_tokens(:expired_token)
    cookies[:browser_token] = create_signed_cookie(:browser_token, token.browser_token)
    post verify_code_session_path, params: { code: token.short_code }
    assert_redirected_to verify_session_path
  end

  test "magic_token signs in with valid token from any browser" do
    token = magic_tokens(:valid_token)
    get magic_token_session_path(token: token.token)
    assert_redirected_to root_path
    assert cookies[:session_id].present?
  end

  test "magic_token rejects expired token" do
    token = magic_tokens(:expired_token)
    get magic_token_session_path(token: token.token)
    assert_redirected_to new_session_path
  end

  test "magic_token rejects invalid token" do
    get magic_token_session_path(token: "bogus")
    assert_redirected_to new_session_path
  end

  test "destroy signs out" do
    sign_in_as(users(:scholar))
    delete session_path
    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end

  test "guest can access root without auth" do
    get root_path
    assert_response :success
  end

  private

  def create_signed_cookie(name, value)
    ActionDispatch::TestRequest.create.cookie_jar.tap do |jar|
      jar.signed[name] = value
    end[name]
  end
end
