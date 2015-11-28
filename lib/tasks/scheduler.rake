desc "Query vehicle/locations from Car2Go and persist them"
task :poll_and_persist_vehicles => :environment do
  vlc = VehicleLocationsController.new
  locations = vlc.get_valid_locations
  locations.each do |location|
    puts "Processing vehicle locations for #{location}"
    record_count = vlc.poll_and_persist location
    puts "Finished processing #{record_count} vehicles for #{location}"
  end
end

desc "Get all valid Car2Go location names"
task :locations => :environment do
  vlc = VehicleLocationsController.new
  puts vlc.get_valid_locations
end
