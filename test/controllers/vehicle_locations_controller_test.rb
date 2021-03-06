# frozen_string_literal: true

require 'test_helper'
require 'vehicle_locations_controller'

MOCK_VEHICLES = [{ 'address' => 'Grand Ave 1600, 55104 St Paul', 'coordinates' => [-93.168740, 44.939976, 0], 'engineType' => 'CE', 'exterior' => 'GOOD', 'fuel' => 100, 'interior' => 'GOOD', 'name' => 'AAA000', 'smartPhoneRequired' => false, 'vin' => 'ABCD0000000000001' },
                 { 'address' => 'W 4th St 90, 55102 St Paul', 'coordinates' => [-93.097176, 44.944101, 0], 'engineType' => 'CE', 'exterior' => 'GOOD', 'fuel' => 39, 'interior' => 'GOOD', 'name' => 'BBB111', 'smartPhoneRequired' => false, 'vin' => 'ABCD0000000000002' },
                 { 'address' => 'Snelling Ave N 510, 55104 St Paul', 'coordinates' => [-93.166811, 44.956653, 0], 'engineType' => 'CE', 'exterior' => 'GOOD', 'fuel' => 21, 'interior' => 'GOOD', 'name' => 'CCC222', 'smartPhoneRequired' => false, 'vin' => 'ABCD0000000000003' }].freeze

MOCK_LOCATIONS = [{ 'countryCode' => 'US', 'defaultLanguage' => 'en', 'locationId' => 29, 'locationName' => 'Twin Cities', 'mapSection' => { 'center' => { 'latitude' => 44.983333, 'longitude' => -93.266667 }, 'lowerRight' => { 'latitude' => 44.723591, 'longitude' => -92.856746 }, 'upperLeft' => { 'latitude' => 45.159339, 'longitude' => -93.549185 } }, 'timezone' => 'America/Chicago' },
                  { 'countryCode' => 'DE', 'defaultLanguage' => 'de', 'locationId' => 26, 'locationName' => 'München', 'mapSection' => { 'center' => { 'latitude' => 48.136981, 'longitude' => 11.577036 }, 'lowerRight' => { 'latitude' => 47.987337, 'longitude' => 11.870041 }, 'upperLeft' => { 'latitude' => 48.419347, 'longitude' => 11.34819 } }, 'timezone' => 'Europe/Berlin' }].freeze

##
# Allow setting of client on class
class VehicleLocationsController
  attr_writer :client
end

class VehicleLocationsControllerTest < ActionController::TestCase
  setup do
    @vehicle_location = vehicle_locations(:one)
    @mock_caruby2go = MiniTest::Mock.new
    @mock_dropbox_client = MiniTest::Mock.new
    @vehicle_locations_controller = VehicleLocationsController.new
    @vehicle_locations_controller.client = @mock_dropbox_client
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:vehicle_locations)
    assert_equal 3, assigns(:vehicle_locations).count
  end

  test 'should get index with location scope' do
    get :index, params: { location: 'amsterdam' }
    assert_response :success
    assert_equal 1, assigns(:vehicle_locations).count
  end

  test 'should get index with interior and location scope' do
    get :index, params: { location: 'twincities', interior: 'good' }
    assert_response :success
    assert_equal 1, assigns(:vehicle_locations).count
    assert_equal 'BBB111', assigns(:vehicle_locations).first.vehicle
  end

  test 'should get index with exterior and location scope' do
    get :index, params: { location: 'amsterdam', exterior: 'unacceptable' }
    assert_response :success
    assert_equal 1, assigns(:vehicle_locations).count
    assert_equal 'A-ZZZ-00', assigns(:vehicle_locations).first.vehicle
  end

  test 'should show vehicle_location' do
    get :show, params: { id: @vehicle_location }
    assert_response :success
  end

  test 'should query car2go and persist records' do
    count = 0
    @mock_caruby2go.expect(:vehicles, MOCK_VEHICLES)
    assert_difference('VehicleLocation.count', 3) do
      Caruby2go.stub(:new, @mock_caruby2go) do
        count = @vehicle_locations_controller.poll_and_persist('saint_paul')
      end
    end
    assert @mock_caruby2go.verify
    assert_equal 3, count
  end

  test 'should query car2go and dropbox JSON' do
    @mock_dropbox_client.expect(:upload, true) do |filename, file|
      filename =~ %r{^/saint_paul-} || file.class.name == 'TempFile'
    end
    @mock_caruby2go.expect(:vehicles, MOCK_VEHICLES)
    assert_difference('VehicleLocation.count', 0) do
      Caruby2go.stub(:new, @mock_caruby2go) do
        assert @vehicle_locations_controller.poll_and_dropbox('saint_paul')
      end
    end
    assert @mock_caruby2go.verify
    assert @mock_dropbox_client.verify
  end

  test 'should return locations URI-encoded' do
    @mock_caruby2go.expect(:locations, MOCK_LOCATIONS)
    @vehicle_locations_controller = VehicleLocationsController.new
    Caruby2go.stub(:new, @mock_caruby2go) do
      @locations = @vehicle_locations_controller.valid_locations
    end
    assert_equal ['M%C3%BCnchen', 'TwinCities'], @locations
    assert @mock_caruby2go.verify
  end
end
