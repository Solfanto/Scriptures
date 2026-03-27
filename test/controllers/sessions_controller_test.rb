require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new renders sign-in page" do
    get new_session_path
    assert_response :success
    assert_select "h1", "Sign in"
  end

  test "create sends magic link email" do
    assert_enqueued_emails 1 do
      post session_path, params: { email_address: "scholar@example.com" }
    end
    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "#notice", /Check your email/
  end

  test "create auto-creates user for new email" do
    assert_difference "User.count", 1 do
      post session_path, params: { email_address: "brand-new@example.com" }
    end
  end

  test "magic_token signs in with valid token" do
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
end
