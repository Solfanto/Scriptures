require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:scholar)) }

  test "show renders account settings" do
    get account_path
    assert_response :success
    assert_select "h1", "Account settings"
  end

  test "update saves display name" do
    patch account_path, params: { user: { display_name: "New Name" } }
    assert_redirected_to account_path
    assert_equal "New Name", users(:scholar).reload.display_name
  end

  test "show requires authentication" do
    sign_out
    get account_path
    assert_redirected_to new_session_path
  end
end
