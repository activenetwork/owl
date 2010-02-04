require 'test_helper'

class AlertHandlersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alert_handlers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create alert_handler" do
    assert_difference('AlertHandler.count') do
      post :create, :alert_handler => { }
    end

    assert_redirected_to alert_handler_path(assigns(:alert_handler))
  end

  test "should show alert_handler" do
    get :show, :id => alert_handlers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => alert_handlers(:one).to_param
    assert_response :success
  end

  test "should update alert_handler" do
    put :update, :id => alert_handlers(:one).to_param, :alert_handler => { }
    assert_redirected_to alert_handler_path(assigns(:alert_handler))
  end

  test "should destroy alert_handler" do
    assert_difference('AlertHandler.count', -1) do
      delete :destroy, :id => alert_handlers(:one).to_param
    end

    assert_redirected_to alert_handlers_path
  end
end
