class AddFilenameToVehicleLocations < ActiveRecord::Migration
  def change
    add_column :vehicle_locations, :filename, :string
  end
end
