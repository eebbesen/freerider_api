require 'test_helper'

class VehicleLocationsControllerTest < ActionController::TestCase
  setup do
    @vehicle_location = vehicle_locations(:vehicle_one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:vehicle_locations)
  end

  test 'should create vehicle_location' do
    assert_difference('VehicleLocation.count') do
      post :create, vehicle_location: { vehicle: 'CCC333', latitude: 1, longitude: -2.3456789 }
    end

    assert_response 201
  end

  test 'should show vehicle_location' do
    get :show, id: @vehicle_location
    assert_response :success
  end

  test 'should update vehicle_location' do
    put :update, id: @vehicle_location, vehicle_location: { vehicle: 'AAA000', latitude: 3, longitude: -2.3456789 }
    assert_response 204
    assert_equal(3, VehicleLocation.find_by_id(@vehicle_location).latitude)
  end

  test 'should destroy vehicle_location' do
    assert_difference('VehicleLocation.count', -1) do
      delete :destroy, id: @vehicle_location
    end

    assert_response 204
  end
end
