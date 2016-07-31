##
# Dropbox map data
class MapToDropbox
  include DropboxPersistence
  def send_map(vehicle_locations)
    payload = convert_to_csv vehicle_locations
    save_to_dropbox payload
  end

  def convert_to_csv(vehicle_locations)
    Tempfile.new("#{vehicle_locations.first.location}-").tap do |t|
      t.write VehicleLocation.attribute_names.join(',')
      vehicle_locations.each do |row|
        t.write "\n" + row.attributes.values.join(',')
      end
    end
  end

  def save_file(file)
    fn = generate_filename file
    client.put_file(fn, file)
    Rails.logger.info "#{fn} saved to Dropbox"
  end

  def client
    @client ||= DropboxClient.new(Rails.application.config.dropbox_maps_token)
  end

  def generate_filename(file)
    city = file.path.split('/').last.split('-').first
    "#{city}-#{DateTime.now.strftime('%Y%m%d_%H%M%S')}"
  end

  def filename_prefix
    'map'
  end
end
