class VehicleLocation < ActiveRecord::Base
  validates_presence_of :vehicle, :latitude, :longitude
end
