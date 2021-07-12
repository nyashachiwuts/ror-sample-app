require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.new(name: "Sean", email: "sean@paul.com", password: "webeburning")
    @user.save!
  end

  test "attempting to login with invalid login details renders a flash message that appears once" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: invalid_login_params
    assert_template "sessions/new"
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "attempting to login with valid login details sets a session and redirects the user to their show page which contains various links" do
    get login_path
    post login_path, params: valid_login_params
    assert session
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url

    # Simulate a user clicking logout in a second window. 
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0 
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  private

  def invalid_login_params
    {
      session: {
        email: "me@body.com",
        password: "mypassword",
      }
    }
  end

  def valid_login_params
    {
      session: {
        email: @user.email,
        password: @user.password,
      }
    }
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_nil cookies['remember_token']
  end

  test "login without remembering" do
      log_in_as(@user, remember_me: '0')
      assert_nil cookies['remember_token']
  end
end
