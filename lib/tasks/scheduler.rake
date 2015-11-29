desc "Query vehicle/locations from Car2Go and persist them"
task :poll_and_persist_vehicles, [:loc] => :environment do |t, args|
  vlc = VehicleLocationsController.new
  locations = args[:loc] ? [args[:loc]] : vlc.valid_locations
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
