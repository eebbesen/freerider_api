require 'test_helper'
require 'date'
require 'dropbox_sdk'

##
# Implementation of module under test
class TestDropboxPersister
  include DropboxPersistence

  def initialize(city, client)
    @city = city
    @client = client
  end

  def set_cursor=(cursor)
    @cursor = cursor
  end
end

##
# Mockish thing to simulate DropboxClient
class TestDropboxClient < DropboxClient
  attr_reader :filename, :file, :token, :called_cursor
  def put_file(filename, file)
    @filename = filename
    @file = file
  end

  def initialize(token)
    @token = token
  end

  def destroyed_files
    @destroyed_files ||= []
  end

  def delta(cursor)
    @called_cursor = cursor

    { 'has_more' => true,
      'cursor' => 'AAGD16CDqUR3_J8VkxqbtaxTLucsv8_YXhBW_qMa8-jqHU5EdR6cZ6kYAC9xA_Q5gocIcSO3GnXcZbUE9aoCSQTpDpW9Q88YyxifdVlcoAaStUuBUdj0JkavZnaQdDBhPsE',
      'entries' => [['/amsterdam-20160103_222646', { 'rev' => '5413a6ecb', 'thumb_exists' => false, 'path' => '/amsterdam-20160103_222646', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'icon' => 'page_white', 'bytes' => 87200, 'modified' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'size' => '85.2 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 5 }], ['/arlingtoncounty-20160103_222649', { 'rev' => '6413a6ecb', 'thumb_exists' => false, 'path' => '/arlingtoncounty-20160103_222649', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'icon' => 'page_white', 'bytes' => 19389, 'modified' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'size' => '18.9 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 6 }]],
      'reset' => true }
  end

  def get_file(_filename)
    '[{"address"=>"W 4th St 90, 55102 Saint Paul", "coordinates"=>[-93.097112, 44.944025, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>36, "interior"=>"GOOD", "name"=>"AB5102", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME000"}, {"address"=>"Marshal Ave 1831, 55104 Saint Paul", "coordinates"=>[-93.177645, 44.949533, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>66, "interior"=>"GOOD", "name"=>"AB5104", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME001"}, {"address"=>"Ford Pkway 1974, 55116 Saint Paul", "coordinates"=>[-93.183036, 44.917769, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>18, "interior"=>"GOOD", "name"=>"AB7740", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME002"}]'
  end

  def destroy(_filename)
    destroyed_files << _filename
  end
end

class DropboxPersistenceTest < ActiveSupport::TestCase
  MOCK_VEHICLES = [{ 'key' => 'val1', 'key2' => 'val2' },
                   { 'key' => 'val1_2', 'key2' => 'val2_2' }]

  setup do
    @fake_dropbox_client = TestDropboxClient.new('yek')
    @dropbox_persistence = TestDropboxPersister.new('GREeN BAY', @fake_dropbox_client)
    ENV['NO_DELETE_DB_FILE'] = nil
  end

  test 'should create a filename in the proper format' do
    assert_equal("greenbay-#{DateTime.now.strftime('%Y%m%d_%H%M%S')}",
                 @dropbox_persistence.send(:filename))
  end

  test 'should create a tempfile' do
    file = @dropbox_persistence.send(:file, MOCK_VEHICLES)
    assert_equal(MOCK_VEHICLES.to_s.size, file.size)
  end

  test 'should persist a file in Dropbox' do
    filename = "greenbay-#{DateTime.now.strftime('%Y%m%d_%H%M%S')}"
    tempfile = Tempfile.new filename
    tempfile.write MOCK_VEHICLES

    @dropbox_persistence.save_to_dropbox(MOCK_VEHICLES)

    assert_equal 'yek', @fake_dropbox_client.token
    assert_equal filename, @fake_dropbox_client.filename
    assert_not_nil @fake_dropbox_client.file
  end

  test 'should get and format new file names' do
    new_file_names = @dropbox_persistence.send(:new_files)

    assert_equal 2, new_file_names.size
    assert_equal 'amsterdam-20160103_222646', new_file_names[0]
  end

  test 'should set cursor from Dropbox call' do
    @dropbox_persistence.send(:new_files)

    assert_not_nil @dropbox_persistence.cursor
  end

  test 'should not error out if no persisted DropboxMetadata' do
    DropboxMetadata.destroy_all

    @dropbox_persistence.send(:new_files)

    assert_equal 'AAGD16CDqUR3_J8VkxqbtaxTLucsv8_YXhBW_qMa8-jqHU5EdR6cZ6kYAC9xA_Q5gocIcSO3GnXcZbUE9aoCSQTpDpW9Q88YyxifdVlcoAaStUuBUdj0JkavZnaQdDBhPsE', @dropbox_persistence.cursor
  end

  test 'should return empty String for cursor if no persisted DropboxMetadata' do
    DropboxMetadata.destroy_all

    assert_equal '', @dropbox_persistence.cursor
  end

  test 'should return Array of data' do
    data = @dropbox_persistence.send(:get_file_data, 'filename')

    assert_equal Array, data.class
    assert_equal 3, data.size
    assert_equal 'HAPPYGOFUNTIME000', data[0]['vin']
  end

  test 'should return data from multiple files' do
    data = @dropbox_persistence.send(:read_from_dropbox)

    assert_equal 2, data.keys.size
    assert_equal 'amsterdam-20160103_222646', data.keys[0]
    assert_equal 'arlingtoncounty-20160103_222649', data.keys[1]
  end

  test 'should persist new cursor value' do
    assert_difference('DropboxMetadata.count', 1) do
      @dropbox_persistence.send(:read_from_dropbox)
    end

    assert_equal 'AAGD16CDqUR3_J8VkxqbtaxTLucsv8_YXhBW_qMa8-jqHU5EdR6cZ6kYAC9xA_Q5gocIcSO3GnXcZbUE9aoCSQTpDpW9Q88YyxifdVlcoAaStUuBUdj0JkavZnaQdDBhPsE', DropboxMetadata.last.cursor
  end

  test 'should use most recent cursor from database when none provided' do
    last_droppbox_metadata = DropboxMetadata.last

    @dropbox_persistence.send(:read_from_dropbox)

    assert_equal last_droppbox_metadata.cursor, @fake_dropbox_client.called_cursor
  end

  test 'should use requested cursor' do
    last_droppbox_metadata = DropboxMetadata.last
    assert_not_equal 'x', last_droppbox_metadata.cursor
    @dropbox_persistence.set_cursor = 'x'

    @dropbox_persistence.send(:read_from_dropbox)

    assert_equal 'x', @fake_dropbox_client.called_cursor
  end

  test 'should persist data and delete file from dropbox' do
    assert_difference 'VehicleLocation.count', 6 do
      @dropbox_persistence.save_from_dropbox
    end
    assert_equal ["amsterdam-20160103_222646",
                  "arlingtoncounty-20160103_222649"],
                 @fake_dropbox_client.destroyed_files
  end

  test 'should persist data but not delete from dropbox when NO_DELETE_DB_FILE' do
    ENV['NO_DELETE_DB_FILE'] = '1'
    assert_difference 'VehicleLocation.count', 6 do
      @dropbox_persistence.save_from_dropbox
    end
    assert_equal [],
                 @fake_dropbox_client.destroyed_files
  end
end
