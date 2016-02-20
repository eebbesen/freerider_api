require 'test_helper'
require 'dropbox_sdk'
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
    @vehicle_location = vehicle_locations(:vehicle_one)
    @mock_caruby2go = MiniTest::Mock.new
    @mock_dropbox_client = MiniTest::Mock.new
    @vehicle_locations_controller = VehicleLocationsController.new
    @vehicle_locations_controller.client = @mock_dropbox_client
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:vehicle_locations)
  end

  test 'should show vehicle_location' do
    get :show, id: @vehicle_location
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
    @mock_dropbox_client.expect(:put_file, true) do |filename, file|
      filename =~ /^saint_paul-/ || file.class.name == 'TempFile'
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

  test 'should persist VehicleLocations and delete files from dropbox' do
    @mock_dropbox_client.expect(:delta,
                                'has_more' => true,
                                'cursor' => 'AAGD16CDqUR3_J8VkxqbtaxTLucsv8_YXhBW_qMa8-jqHU5EdR6cZ6kYAC9xA_Q5gocIcSO3GnXcZbUE9aoCSQTpDpW9Q88YyxifdVlcoAaStUuBUdj0JkavZnaQdDBhPsE',
                                'entries' => [['/amsterdam-20160103_222646', { 'rev' => '5413a6ecb', 'thumb_exists' => false, 'path' => '/amsterdam-20160103_222646', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'icon' => 'page_white', 'bytes' => 87_200, 'modified' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'size' => '85.2 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 5 }], ['/arlingtoncounty-20160103_222649', { 'rev' => '6413a6ecb', 'thumb_exists' => false, 'path' => '/arlingtoncounty-20160103_222649', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'icon' => 'page_white', 'bytes' => 19_389, 'modified' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'size' => '18.9 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 6 }]],
                                'reset' => true
                               )
    [/^amsterdam/, /^arlington/].each do |file_prefix|
      @mock_dropbox_client.expect(:get_file, MOCK_VEHICLES.to_s) do |filename|
        filename =~ file_prefix
      end
      @mock_dropbox_client.expect(:file_delete, true) do |filename|
        filename =~ file_prefix
      end
    end
    Caruby2go.stub(:new, @mock_caruby2go) do
      assert_difference 'VehicleLocation.count', 6 do
        @vehicle_locations_controller.send :save_from_dropbox
      end
    end
    assert @mock_dropbox_client.verify
  end
end
