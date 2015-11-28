class AddLocationToVehicleLocations < ActiveRecord::Migration
  def change
    add_column :vehicle_locations, :location, :string
  end
end
