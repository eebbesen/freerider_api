require 'test_helper'
require 'date'
require 'dropbox_sdk'

##
# Implementation of module under test
class TestDropboxPersister
  include DropboxPersistence

  def initialize(filename_prefix, client)
    @filename_prefix = filename_prefix
    @client = client
  end

  def client
    @client
  end
end

##
# Mockish thing to simulate DropboxClient
class TestDropboxClientDP
  attr_reader :filename, :file, :token, :data

  def initialize(token)
    @token = token
    @data = '[{"address"=>"W 4th St 90, 55102 Saint Paul", "coordinates"=>[-93.097112, 44.944025, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>36, "interior"=>"GOOD", "name"=>"AB5102", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME000"}, {"address"=>"Marshal Ave 1831, 55104 Saint Paul", "coordinates"=>[-93.177645, 44.949533, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>66, "interior"=>"GOOD", "name"=>"AB5104", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME001"}, {"address"=>"Ford Pkway 1974, 55116 Saint Paul", "coordinates"=>[-93.183036, 44.917769, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>18, "interior"=>"GOOD", "name"=>"AB7740", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME002"}]'
  end

  def put_file(filename, file)
    @filename = filename
    @file = file
  end

  def destroyed_files
    @destroyed_files ||= []
  end

  def delta
    { 'has_more' => true,
      'cursor' => 'AAGD16CDqUR3_J8VkxqbtaxTLucsv8_YXhBW_qMa8-jqHU5EdR6cZ6kYAC9xA_Q5gocIcSO3GnXcZbUE9aoCSQTpDpW9Q88YyxifdVlcoAaStUuBUdj0JkavZnaQdDBhPsE',
      'entries' => [['/amsterdam-20160103_222646', { 'rev' => '5413a6ecb', 'thumb_exists' => false, 'path' => '/amsterdam-20160103_222646', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'icon' => 'page_white', 'bytes' => 87200, 'modified' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'size' => '85.2 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 5 }], ['/arlingtoncounty-20160103_222649', { 'rev' => '6413a6ecb', 'thumb_exists' => false, 'path' => '/arlingtoncounty-20160103_222649', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'icon' => 'page_white', 'bytes' => 19389, 'modified' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'size' => '18.9 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 6 }]],
      'reset' => true }
  end

  def get_file(_filename)
    @data
  end

  def file_delete(_filename)
    destroyed_files << _filename
  end

  def data=(data)
    @data = data
  end
end

class DropboxPersistenceTest < ActiveSupport::TestCase
  MOCK_VEHICLES = [{ 'key' => 'val1', 'key2' => 'val2' },
                   { 'key' => 'val1_2', 'key2' => 'val2_2' }]

  setup do
    @fake_dropbox_client = TestDropboxClientDP.new('yek')
    @fake_dropbox_client.data = '[{"address"=>"W 4th St 90, 55102 Saint Paul", "coordinates"=>[-93.097112, 44.944025, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>36, "interior"=>"GOOD", "name"=>"AB5102", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME000"}, {"address"=>"Marshal Ave 1831, 55104 Saint Paul", "coordinates"=>[-93.177645, 44.949533, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>66, "interior"=>"GOOD", "name"=>"AB5104", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME001"}, {"address"=>"Ford Pkway 1974, 55116 Saint Paul", "coordinates"=>[-93.183036, 44.917769, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>18, "interior"=>"GOOD", "name"=>"AB7740", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME002"}]'
    @dropbox_persistence = TestDropboxPersister.new('GREeN BAY', @fake_dropbox_client)
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

  test 'should delete file from dropbox when no block' do
    @dropbox_persistence.delete_from_dropbox 'amsterdam-20160103_222646'

    assert_equal ['amsterdam-20160103_222646'],
                 @fake_dropbox_client.destroyed_files
  end

  test 'should put file in Dropbox' do
    @dropbox_persistence.send(:save_file, MOCK_VEHICLES)
    assert_equal "greenbay-#{DateTime.now.strftime('%Y%m%d_%H%M%S')}", @fake_dropbox_client.filename
    assert_not_nil @fake_dropbox_client.file
  end

  test 'should create a filename in the proper format when filename_prefix not nil' do
    assert_equal("greenbay-#{DateTime.now.strftime('%Y%m%d_%H%M%S')}",
                 @dropbox_persistence.send(:generate_filename))
  end

  test 'should create a filename in the proper format when filename_prefix is nil' do
    @dropbox_persistence = TestDropboxPersister.new('deFAUlt_fileName_preFIX', @fake_dropbox_client)
    assert_equal("default_filename_prefix-#{DateTime.now.strftime('%Y%m%d_%H%M%S')}",
                 @dropbox_persistence.send(:generate_filename))
  end

  test 'should create a tempfile' do
    file = @dropbox_persistence.send(:file, MOCK_VEHICLES)
    assert_equal(MOCK_VEHICLES.to_s.size, file.size)
  end

  test 'should get and format new file names' do
    new_file_names = @dropbox_persistence.send(:new_filenames)

    assert_equal 2, new_file_names.size
    assert_equal 'amsterdam-20160103_222646', new_file_names[0]
  end

  test 'should return Array of data' do
    data = @dropbox_persistence.send(:get_file_data, 'filename')

    assert_equal Array, data.class
    assert_equal 3, data.size
    assert_equal 'HAPPYGOFUNTIME000', data[0]['vin']
  end

  test 'should return an empty Array when no records' do
    @fake_dropbox_client.data = '[]'
    data = @dropbox_persistence.send(:get_file_data, 'filename')

    assert_equal Array, data.class
    assert_equal 0, data.size
  end
end
