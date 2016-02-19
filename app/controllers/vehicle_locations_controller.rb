class VehicleLocationsController < ApplicationController
  include DropboxPersistence

  before_action :set_vehicle_location, only: [:show, :update, :destroy]

  # GET /vehicle_locations
  # GET /vehicle_locations.json
  def index
    @vehicle_locations = VehicleLocation.all

    render json: @vehicle_locations
  end

  # GET /vehicle_locations/1
  # GET /vehicle_locations/1.json
  def show
    render json: @vehicle_location
  end

  # POST /vehicle_locations
  # POST /vehicle_locations.json
  def create
    @vehicle_location = VehicleLocation.new(vehicle_location_params)
    if @vehicle_location.save
      render json: @vehicle_location, status: :created, location: @vehicle_location
    else
      render json: @vehicle_location.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /vehicle_locations/1
  # PATCH/PUT /vehicle_locations/1.json
  def update
    @vehicle_location = VehicleLocation.find(params[:id])

    if @vehicle_location.update(vehicle_location_params)
      head :no_content
    else
      render json: @vehicle_location.errors, status: :unprocessable_entity
    end
  end

  # DELETE /vehicle_locations/1
  # DELETE /vehicle_locations/1.json
  def destroy
    @vehicle_location.destroy

    head :no_content
  end

  # saves each VehicleLocation to a database
  def poll_and_persist(location = 'twincities')
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
  def poll_and_dropbox(location = 'twincities')
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

  private

  def poll(location = 'twincities')
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
    ENV['RUNSCOPE_KEY'] ? Caruby2go.new(ENV['CONSUMER_KEY'], location, "https://www-car2go-com-#{RUNSCOPE_KEY}.runscope.net/api/v2.1") : Caruby2go.new(ENV['CONSUMER_KEY'], location)
  end

  def filename_prefix
    @city || 'no_location'
  end

  def save_from_dropbox
    new_filenames.each do |new_filename|
      VehicleLocation.transaction do
        count = 0
        get_file_data(new_filename).each do |vl|
          VehicleLocation.from_json(vl.merge({filename: new_filename})).save!
          count = count + 1
        end
        Rails.logger.info "Processed #{count} records for #{new_filename}"
      end
      delete_from_dropbox new_filename
    end
  end
end
