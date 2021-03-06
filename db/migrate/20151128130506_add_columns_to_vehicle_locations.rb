# frozen_string_literal: true

class AddColumnsToVehicleLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :vehicle_locations, :exterior, :string
    add_column :vehicle_locations, :interior, :string
    add_column :vehicle_locations, :vin, :string

    add_index :vehicle_locations, :vehicle
    add_index :vehicle_locations, :vin
  end
end
