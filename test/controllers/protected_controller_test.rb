require "test_helper"

class ProtectedControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get protected_index_url
    assert_response :success
  end
end
