desc "Query vehicle/locations from Car2Go and persist them"
task :poll_and_persist_vehicles => :environment do
  location = 'twincities'
  puts "Processing vehicle locations for #{location}"
  vlc = VehicleLocationsController.new
  record_count = vlc.poll_and_persist
  puts "Finished processing #{record_count} vehicles for #{location}"
end
