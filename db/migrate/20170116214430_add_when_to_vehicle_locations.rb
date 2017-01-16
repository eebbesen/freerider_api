class AddWhenToVehicleLocations < ActiveRecord::Migration
  def change
    add_column :vehicle_locations, :when, :datetime
  end
end
