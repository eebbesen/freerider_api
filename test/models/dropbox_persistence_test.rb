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
end

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

  def delta(cursor)
    cursor = 'AAGD16CDqUR3_J8VkxqbtaxTLucsv8_YXhBW_qMa8-jqHU5EdR6cZ6kYAC9xA_Q5gocIcSO3GnXcZbUE9aoCSQTpDpW9Q88YyxifdVlcoAaStUuBUdj0JkavZnaQdDBhPsE'
    { 'has_more' => true,
      'cursor' => cursor,
      'entries' => [['/amsterdam-20160103_222646', { 'rev' => '5413a6ecb', 'thumb_exists' => false, 'path' => '/amsterdam-20160103_222646', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'icon' => 'page_white', 'bytes' => 87200, 'modified' => 'Mon, 04 Jan 2016 04:26:47 +0000', 'size' => '85.2 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 5 }], ['/arlingtoncounty-20160103_222649', { 'rev' => '6413a6ecb', 'thumb_exists' => false, 'path' => '/arlingtoncounty-20160103_222649', 'is_dir' => false, 'client_mtime' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'icon' => 'page_white', 'bytes' => 19389, 'modified' => 'Mon, 04 Jan 2016 04:26:49 +0000', 'size' => '18.9 KB', 'root' => 'app_folder', 'mime_type' => 'application/octet-stream', 'revision' => 6 }]],
      'reset' => true }
  end
end

class DropboxPersistenceTest < ActiveSupport::TestCase
  MOCK_VEHICLES = [{ 'key' => 'val1', 'key2' => 'val2' },
                   { 'key' => 'val1_2', 'key2' => 'val2_2' }]

  setup do
    @fake_dropbox_client = TestDropboxClient.new('yek')
    @dropbox_persistence = TestDropboxPersister.new('GREeN BAY', @fake_dropbox_client)
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
    # put_file called
    assert_equal filename, @fake_dropbox_client.filename
    assert_not_nil @fake_dropbox_client.file
  end

  test "should make 'DropboxClient#delta' call" do
    new_file_names = @dropbox_persistence.send(:new_files)

    assert_equal 2, new_file_names.size
    assert_equal 'amsterdam-20160103_222646', new_file_names[0]
  end

  test 'should persist cursor from Dropbox call' do

  end
end
