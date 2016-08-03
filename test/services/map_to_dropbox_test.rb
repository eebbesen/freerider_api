require 'test_helper'
require 'map_to_dropbox'

##
# will need to set client to mock
class MapToDropbox
  attr_writer :client
end

class MapToDropboxTest < ActiveSupport::TestCase
  include DropboxPersistence

  MOCK_VEHICLES = [{ 'key' => 'val1', 'key2' => 'val2' },
                   { 'key' => 'val1_2', 'key2' => 'val2_2' }].freeze

  setup do
    @fake_dropbox_client = TestDropboxClient.new('yek')
    @dropbox_persistence = MapToDropbox.new
    @dropbox_persistence.client = @fake_dropbox_client
  end

  test 'should convert data to file' do
    validate_file @dropbox_persistence.convert_to_csv(VehicleLocation.all)
  end

  test 'should persist a file in Dropbox' do
    filename = "amsterdam-#{DateTime.now.strftime('%Y%m%d_%H%M%S')}.csv"

    @dropbox_persistence.send_map VehicleLocation.all

    assert_equal 'yek', @fake_dropbox_client.token
    assert_equal filename, @fake_dropbox_client.filename
    assert_not_nil @fake_dropbox_client.file
    validate_file @fake_dropbox_client.file
  end

  private

  def validate_file(file)
    file.rewind
    data = file.read.split "\n"
    assert_equal 4, data.count
    assert_equal 'id', data[0].split(',')[0]
    assert_equal 'A-ZZZ-00', data[1].split(',')[1]
  end
end
