# frozen_string_literal: true

class AddWhenToVehicleLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :vehicle_locations, :when, :datetime
  end
end
