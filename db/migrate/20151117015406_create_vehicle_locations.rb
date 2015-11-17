class CreateVehicleLocations < ActiveRecord::Migration
  def change
    create_table :vehicle_locations do |t|
      t.string :vehicle
      t.float :longitude
      t.float :latitude
      t.datetime :created_at
    end
  end
end
