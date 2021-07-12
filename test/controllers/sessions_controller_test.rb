require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET #login responds with success" do
    get login_path
    assert_response :success
  end
end
