require 'test_helper'

class VehicleLocationTest < ActiveSupport::TestCase
  should validate_presence_of :vehicle
  should validate_presence_of :latitude
  should validate_presence_of :longitude
  should validate_presence_of :location
  should validate_presence_of :vin

  test 'initialize from JSON' do
    json = { 'address': 'W 4th St 90, 55102 Saint Paul',
             # coordinates[longitude, latitude]
             'coordinates': [-93.097112, 44.944025, 0],
             'engineType': 'CE',
             'exterior': 'GOOD',
             'fuel': 36,
             'interior': 'GOOD',
             'name': 'AB5102',
             'smartPhoneRequired': false,
             'vin': 'HAPPYGOFUNTIME000' }

    VehicleLocation.from_json(json)
  end
end
