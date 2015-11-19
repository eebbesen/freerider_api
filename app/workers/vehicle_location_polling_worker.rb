class VehicleLocationPollingWorker
  include Sidekiq::Worker

  def perform(city)
    caruby2go = Caruby2go.new(ENV['CONSUMER_KEY'], city)
    response = caruby2go.vehicles
    response.each do |record|
      # Caruby2go provides [longitude, latitude]
      coordinates = record[:coordinates]
      vehicle_location = VehicleLocation.new(vehicle: record[:name],
        longitude: coordinates[0], latitude: coordinates[1])
      vehicle_location.save!
    end
  end
end
