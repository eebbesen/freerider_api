# frozen_string_literal: true

class VehicleLocationsController < ApplicationController
  include DropboxPersistence

  DEFAULT_LOC = 'austin'

  before_action :set_vehicle_location, only: [:show]

  # GET /vehicle_locations
  # GET /vehicle_locations.json
  def index
    @vehicle_locations = VehicleLocation.where(nil)
    @vehicle_locations = @vehicle_locations.location(params[:location]) if params[:location].present?
    @vehicle_locations = @vehicle_locations.interior(params[:interior]) if params[:interior].present?
    @vehicle_locations = @vehicle_locations.exterior(params[:exterior]) if params[:exterior].present?

    render json: @vehicle_locations
  end

  # GET /vehicle_locations/1
  # GET /vehicle_locations/1.json
  def show
    render json: @vehicle_location
  end

  # saves each VehicleLocation to a database
  def poll_and_persist(location = DEFAULT_LOC)
    records_persisted = 0
    poll(location).each do |record|
      # Caruby2go provides coordinates in [longitude, latitude]
      coordinates = record['coordinates']
      vehicle_location = VehicleLocation.new(vehicle: record['name'],
                                             longitude: coordinates[0],
                                             latitude: coordinates[1],
                                             location: location,
                                             vin: record['vin'],
                                             exterior: record['exterior'],
                                             interior: record['interior'])
      vehicle_location.save!
      records_persisted += 1
    end
    records_persisted
  end

  # saves JSON for location to a file on Dropbox
  def poll_and_dropbox(location = DEFAULT_LOC)
    @city = location
    save_to_dropbox poll(location)
  end

  # return valid locations encoded and de-spaced for valid calls
  def valid_locations
    locations = caruby2go_client.locations.collect do |loc|
      URI.escape(loc['locationName'].gsub(/\s+/, ''))
    end
    locations.sort
  end

  def save_from_dropbox
    new_filenames.each do |new_filename|
      nf = "/#{new_filename}"
      VehicleLocation.transaction do
        count = 0
        get_file_data(nf).each do |vl|
          VehicleLocation.from_json(vl.merge(filename: new_filename)).save!
          count += 1
        end
        Rails.logger.info "Processed #{count} records for #{new_filename}"
      end
      delete_from_dropbox nf
    end
  end

  private

  def poll(location = DEFAULT_LOC)
    caruby2go_client(location).vehicles
  end

  def set_vehicle_location
    @vehicle_location = VehicleLocation.find(params[:id])
  end

  def vehicle_location_params
    params.require(:vehicle_location).permit(:vehicle,
                                             :latitude,
                                             :longitude,
                                             :location,
                                             :vin,
                                             :exterior,
                                             :interior)
  end

  def caruby2go_client(location = nil)
    ENV['RUNSCOPE_KEY'] ? Caruby2go.new(ENV['CONSUMER_KEY'], location, "https://www-car2go-com-#{ENV['RUNSCOPE_KEY']}.runscope.net/api/v2.1") : Caruby2go.new(ENV['CONSUMER_KEY'], location)
  end

  def filename_prefix
    @city || 'no_location'
  end
end
