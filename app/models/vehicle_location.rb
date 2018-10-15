# frozen_string_literal: true

class VehicleLocation < ActiveRecord::Base
  validates_presence_of :vehicle, :latitude, :longitude, :location, :vin

  scope :location,  ->(location) { where location: location.downcase }
  scope :exterior,  ->(exterior) { where exterior: exterior.upcase }
  scope :interior,  ->(interior) { where interior: interior.upcase }
  scope :last_days, ->(days) { where(['created_at > ?', Time.now - days.days]) }

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
      vl.filename = args['filename'] if args['filename']
      vl.when = extract_when_from_filename(args['filename']) if args['filename']
    end
  end

  def self.extract_when_from_filename(filename)
    return unless filename

    dt = filename.split('-').last
    d, t = dt.split('_')
    date = d.sub(/(\d{4})(\d{2})(\d{2})/, '\\1-\\2-\\3')
    time = t.sub(/(\d{2})(\d{2})(\d{2})/, '\\1:\\2:\\3')
    "#{date} #{time}"
  end
end
