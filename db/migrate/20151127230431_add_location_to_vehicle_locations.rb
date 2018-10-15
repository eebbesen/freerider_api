# frozen_string_literal: true

class AddLocationToVehicleLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :vehicle_locations, :location, :string
  end
end
