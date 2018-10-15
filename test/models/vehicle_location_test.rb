require 'test_helper'

class VehicleLocationTest < ActiveSupport::TestCase
  # should validate_presence_of :vehicle
  # should validate_presence_of :latitude
  # should validate_presence_of :longitude
  # should validate_presence_of :location
  # should validate_presence_of :vin

  test 'respect location scope' do
    locations = VehicleLocation.where(nil).location('amsterdam')
    assert_equal 1, locations.count
    assert_equal 'amsterdam', locations.first.location
  end

  test 'respect interior scope' do
    vehicle_locations = VehicleLocation.where(nil).interior('unacceptable')
    assert_equal 1, vehicle_locations.count
    assert_equal 'AAA000', vehicle_locations.first.vehicle
  end

  test 'respect exterior scope' do
    vehicle_locations = VehicleLocation.where(nil).exterior('good')
    assert_equal 2, vehicle_locations.count
    vehicle_locations.each do |vehicle_location|
      assert_not_equal 'A-ZZZ-00', vehicle_location.vehicle
    end
  end

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

    expected = VehicleLocation.new(vehicle: 'AB5102',
                                   longitude: -93.097112,
                                   latitude: 44.944025,
                                   created_at: nil,
                                   location: nil,
                                   exterior: 'GOOD',
                                   interior: 'GOOD',
                                   vin: 'HAPPYGOFUNTIME000',
                                   filename: nil,
                                   when: nil)

    row = VehicleLocation.from_json(json)

    assert_equal expected.attributes, row.attributes
  end

  test 'initialize from JSON with filename' do
    json = { 'address': 'W 4th St 90, 55102 Saint Paul',
             # coordinates[longitude, latitude]
             'coordinates': [-93.097112, 44.944025, 0],
             'engineType': 'CE',
             'exterior': 'GOOD',
             'fuel': 36,
             'interior': 'GOOD',
             'name': 'AB5102',
             'smartPhoneRequired': false,
             'vin': 'HAPPYGOFUNTIME000',
             'filename': 'twincities-20161217_190110' }

    expected = VehicleLocation.new(vehicle: 'AB5102',
                                   longitude: -93.097112,
                                   latitude: 44.944025,
                                   created_at: nil,
                                   location: 'twincities',
                                   exterior: 'GOOD',
                                   interior: 'GOOD',
                                   vin: 'HAPPYGOFUNTIME000',
                                   filename: 'twincities-20161217_190110',
                                   when: '2016-12-17 19:01:10')

    row = VehicleLocation.from_json(json)

    assert_equal expected.attributes, row.attributes
  end

  test 'last days scope all included' do
    vs = VehicleLocation.last_days 2
    assert_equal 3, vs.count
  end

  test 'last days scope one excluded' do
    VehicleLocation.first.update_attribute(:created_at, Time.now - 3.days)
    vs = VehicleLocation.last_days 2
    assert_equal 2, vs.count
  end

  test 'last days scope all excluded' do
    VehicleLocation.all.map{|m| m.update_attribute(:created_at, Time.now - 3.days)}
    vs = VehicleLocation.last_days 2
    assert_equal 0, vs.count
  end

  test '#extract_when_from_filename' do
    assert_equal '2016-12-17 19:01:10', VehicleLocation.extract_when_from_filename('twincities-20161217_190110')
  end

  test '#extract_when_from_filename nil value' do
    assert_equal nil, VehicleLocation.extract_when_from_filename(nil)
  end
end
