desc "Query vehicle/locations from Car2Go and persist them"
task :poll_and_persist_vehicles => :environment do
  vlc = VehicleLocationsController.new
  locations = vlc.valid_locations
  locations.each do |location|
    puts "Processing vehicle locations for #{URI.decode location}"
    record_count = vlc.poll_and_persist location
    puts "Finished processing #{record_count} vehicles for #{URI.decode location}\n"
  end
end

desc "Get all valid Car2Go location names"
task :locations => :environment do
  vlc = VehicleLocationsController.new
  puts vlc.valid_locations
end
