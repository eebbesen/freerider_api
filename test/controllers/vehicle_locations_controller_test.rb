require 'test_helper'
require 'dropbox_sdk'
require 'vehicle_locations_controller'

##
# Mockish thing to simulate DropboxClient
class TestDropboxClient < DropboxClient
  attr_reader :filename, :file, :token
  def put_file(filename, file)
    @filename = filename
    @file = file
  end

  def initialize(token)
    @token = token
  end
end

##
# Allow setting of client on class
class VehicleLocationsController
  attr_writer :client
end

class VehicleLocationsControllerTest < ActionController::TestCase
  MOCK_VEHICLES = [{ 'address' => 'Grand Ave 1600, 55104 St Paul', 'coordinates' => [-93.168740, 44.939976, 0], 'engineType' => 'CE', 'exterior' => 'GOOD', 'fuel' => 100, 'interior' => 'GOOD', 'name' => 'AAA000', 'smartPhoneRequired' => false, 'vin' => 'ABCD0000000000001' },
                   { 'address' => 'W 4th St 90, 55102 St Paul', 'coordinates' => [-93.097176, 44.944101, 0], 'engineType' => 'CE', 'exterior' => 'GOOD', 'fuel' => 39, 'interior' => 'GOOD', 'name' => 'BBB111', 'smartPhoneRequired' => false, 'vin' => 'ABCD0000000000002' },
                   { 'address' => 'Snelling Ave N 510, 55104 St Paul', 'coordinates' => [-93.166811, 44.956653, 0], 'engineType' => 'CE', 'exterior' => 'GOOD', 'fuel' => 21, 'interior' => 'GOOD', 'name' => 'CCC222', 'smartPhoneRequired' => false, 'vin' => 'ABCD0000000000003' }]

  MOCK_LOCATIONS = [{ 'countryCode' =>'US', 'defaultLanguage' =>'en', 'locationId' =>29, 'locationName' =>'Twin Cities', 'mapSection' =>{'center' =>{'latitude' =>44.983333, 'longitude' =>-93.266667}, 'lowerRight' =>{'latitude' =>44.723591, 'longitude' =>-92.856746}, 'upperLeft' =>{'latitude' =>45.159339, 'longitude' =>-93.549185}}, 'timezone' =>'America/Chicago' },
                    { 'countryCode' =>'DE', 'defaultLanguage' =>'de', 'locationId' =>26, 'locationName' =>'München', 'mapSection' =>{'center' =>{'latitude' =>48.136981, 'longitude' =>11.577036}, 'lowerRight' =>{'latitude' =>47.987337, 'longitude' =>11.870041}, 'upperLeft' =>{'latitude' =>48.419347, 'longitude' =>11.34819}}, 'timezone' =>'Europe/Berlin' }]

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
      post :create, vehicle_location: { vehicle: 'CCC333', latitude: 1, longitude: -2.3456789, location: 'twincities', vin: 'ABCD0000000000001' }
    end

    assert_response 201
  end

  test 'fail on create' do
    post :create, vehicle_location: { vehicle: nil }
    assert_response :unprocessable_entity
  end

  test 'should show vehicle_location' do
    get :show, id: @vehicle_location
    assert_response :success
  end

  test 'should update vehicle_location' do
    put :update, id: @vehicle_location, vehicle_location: { vehicle: 'AAA000', latitude: 3, longitude: -2.3456789, location: 'twincities', vin: 'ABCD0000000000001' }
    assert_response 204
    assert_equal(3, VehicleLocation.find_by_id(@vehicle_location).latitude)
  end

  test 'fail on update' do
    patch :update, id: @vehicle_location, vehicle_location: { vehicle: nil }
    assert_response :unprocessable_entity
  end

  test 'should destroy vehicle_location' do
    assert_difference('VehicleLocation.count', -1) do
      delete :destroy, id: @vehicle_location
    end

    assert_response 204
  end

  test 'should query car2go and persist records' do
    count = 0
    mock_caruby2go = MiniTest::Mock.new
    mock_caruby2go.expect(:vehicles, MOCK_VEHICLES)
    vehicle_locations_controller = VehicleLocationsController.new
    assert_difference('VehicleLocation.count', 3) do
      Caruby2go.stub(:new, mock_caruby2go) do
        count = vehicle_locations_controller.poll_and_persist('saint_paul')
      end
    end
    assert mock_caruby2go.verify
    assert_equal 3, count
  end

  test 'should query car2go and dropbox JSON' do
    fake_dropbox_client = TestDropboxClient.new('yek')
    mock_caruby2go = MiniTest::Mock.new
    mock_caruby2go.expect(:vehicles, MOCK_VEHICLES)
    vehicle_locations_controller = VehicleLocationsController.new
    vehicle_locations_controller.client = fake_dropbox_client
    assert_difference('VehicleLocation.count', 0) do
      Caruby2go.stub(:new, mock_caruby2go) do
        assert vehicle_locations_controller.poll_and_dropbox('saint_paul')
      end
    end
    assert mock_caruby2go.verify
  end

  test 'should return locations URI-encoded' do
    mock_caruby2go = MiniTest::Mock.new
    mock_caruby2go.expect(:locations, MOCK_LOCATIONS)
    vehicle_locations_controller = VehicleLocationsController.new
    Caruby2go.stub(:new, mock_caruby2go) do
      @locations = vehicle_locations_controller.valid_locations
    end
    assert_equal ['M%C3%BCnchen', 'TwinCities'], @locations
  end
end
