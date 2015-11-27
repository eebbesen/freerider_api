require 'test_helper'

class VehicleLocationsControllerTest < ActionController::TestCase
  MOCK_DATA = [{ "address"=> 'Grand Ave 1600, 55104 St Paul', "coordinates"=> [-93.168740, 44.939976, 0], "engineType"=> 'CE', "exterior"=> 'GOOD', "fuel"=> 100, "interior"=> 'GOOD', "name"=> 'AAA000', "smartPhoneRequired"=> false, "vin"=> 'ABCD0000000000001' },
               { "address"=> 'W 4th St 90, 55102 St Paul', "coordinates"=> [-93.097176, 44.944101, 0], "engineType"=> 'CE', "exterior"=> 'GOOD', "fuel"=> 39, "interior"=> 'GOOD', "name"=> 'BBB111', "smartPhoneRequired"=> false, "vin"=> 'ABCD0000000000002' },
               { "address"=> 'Snelling Ave N 510, 55104 St Paul', "coordinates"=> [-93.166811, 44.956653, 0], "engineType"=> 'CE', "exterior"=> 'GOOD', "fuel"=> 21, "interior"=> 'GOOD', "name"=> 'CCC222', "smartPhoneRequired"=> false, "vin"=> 'ABCD0000000000003' }]

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

  test 'should query car2go and persist records' do
    record_count = 0
    mock_caruby2go = MiniTest::Mock.new
    mock_caruby2go.expect(:vehicles, MOCK_DATA)
    vehicle_locations_controller = VehicleLocationsController.new
    assert_difference('VehicleLocation.count', 3) do
      Caruby2go.stub(:new, mock_caruby2go) do
        record_count = vehicle_locations_controller.poll_and_persist('saint_paul')
      end
    end
    assert mock_caruby2go.verify
    assert_equal 3, record_count
  end
end
