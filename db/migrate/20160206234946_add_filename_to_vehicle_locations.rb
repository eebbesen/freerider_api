# frozen_string_literal: true

class AddFilenameToVehicleLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :vehicle_locations, :filename, :string
  end
end
