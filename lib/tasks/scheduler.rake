desc 'Query vehicle/locations from Car2Go and persist them to server-local database'
task :poll_and_persist_vehicles, [:loc] => :environment do |_t, args|
  vlc = VehicleLocationsController.new
  locations = args[:loc] ? [args[:loc]] : vlc.valid_locations
  locations.each do |location|
    Rails.logger.info "Processing vehicle locations for #{URI.decode location}"
    record_count = vlc.poll_and_persist location
    Rails.logger.info "Finished processing #{record_count} vehicles for #{URI.decode location}\n"
  end
end

desc 'Query vehicle/locations from Car2Go and persist JSON in Dropbox'
task :poll_and_dropbox_vehicles, [:loc] => :environment do |_t, args|
  vlc = VehicleLocationsController.new
  locations = args[:loc] ? [args[:loc]] : vlc.valid_locations
  locations.each do |location|
    Rails.logger.debug "Processing vehicle locations for #{URI.decode location}"
    success = vlc.poll_and_dropbox location
    Rails.logger.info "Successfully processed vehicles for #{URI.decode location}\n" if success
    Rails.logger.info "Error processing vehicles for #{URI.decode location}\n" unless success
  end
end

desc 'Get all valid Car2Go location names'
task locations: :environment do
  vlc = VehicleLocationsController.new
  puts vlc.valid_locations
end
