class VehicleLocation < ActiveRecord::Base
  validates_presence_of :vehicle, :latitude, :longitude, :location, :vin

  def self.from_json(args)
    args = args.with_indifferent_access
    VehicleLocation.new do |vl|
      vl.vehicle = args['name']
      # coordinates[longitude, latitude]
      vl.longitude = args['coordinates'][0] if args['coordinates']
      vl.latitude = args['coordinates'][1] if args['coordinates']
      vl.location = args['filename'].split('-').first if args['filename']
      vl.vin = args['vin']
      vl.exterior = args['exterior']
      vl.interior = args['interior']
      vl.filename = args['filename']
    end
  end
end
