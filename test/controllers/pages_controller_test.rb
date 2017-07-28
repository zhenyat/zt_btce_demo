require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get pages_home_url
    assert_response :success
  end

  test "should get public_api" do
    get pages_public_api_url
    assert_response :success
  end

  test "should get trade_api" do
    get pages_trade_api_url
    assert_response :success
  end

end
