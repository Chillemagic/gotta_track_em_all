require "test_helper"

class TrackerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tracker_index_url
    assert_response :success
  end

  test "should get show" do
    get tracker_show_url
    assert_response :success
  end
end
