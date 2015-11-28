require 'test_helper'

class VehicleLocationTest < ActiveSupport::TestCase
  should validate_presence_of :vehicle
  should validate_presence_of :latitude
  should validate_presence_of :longitude
  should validate_presence_of :location
  should validate_presence_of :vin
end
