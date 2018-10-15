# frozen_string_literal: true

class CreateVehicleLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :vehicle_locations do |t|
      t.string :vehicle, null: false
      t.float :longitude, null: false
      t.float :latitude, null: false
      t.datetime :created_at, null: false
    end
  end
end
