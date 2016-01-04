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
    tempfile.write MOCK_VEHICLES\

    @dropbox_persistence.save_to_dropbox(MOCK_VEHICLES)

    assert 'yek', @fake_dropbox_client.token
    # put_file called
    assert filename, @fake_dropbox_client.filename
    assert_not_nil @fake_dropbox_client.file
  end
end
