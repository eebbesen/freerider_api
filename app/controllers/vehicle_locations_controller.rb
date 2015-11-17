class VehicleLocationsController < ApplicationController
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

  private

    def set_vehicle_location
      @vehicle_location = VehicleLocation.find(params[:id])
    end

    def vehicle_location_params
      params.require(:vehicle_location).permit(:vehicle, :latitude, :longitude)
    end
end
