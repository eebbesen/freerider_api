require 'dropbox_sdk'
require 'tempfile'

##
# Prep data and persist in dropbox
# Retrieve data from dropbox
module DropboxPersistence
  extend ActiveSupport::Concern

  def save_to_dropbox(data)
    save_file data
  end

  def save_from_dropbox
    read_from_dropbox
  end

  def cursor
    @cursor ||= DropboxMetadata.last ? DropboxMetadata.last.cursor : ''
  end

  private

  def file(data)
    file = Tempfile.new filename
    file.write data
    file
  end

  def save_file(data)
    client.put_file(filename, file(data))
  end

  def new_files
    delta = client.delta cursor
    filenames = delta['entries'].each.map do |record|
      record[0].gsub(%r{^/}, '')
    end
    @cursor = delta['cursor']
    filenames
  end

  def get_file_data(filename)
    file = client.get_file filename
    data = file.gsub(%r{=>}, ':')
    ActiveSupport::JSON.decode(data)
  end

  def read_from_dropbox
    new_files.each do |new_filename|
      get_file_data(new_filename).each do |vl|
        VehicleLocation.from_json(vl.merge({filename: new_filename})).save!
      end
      Rails.logger.info "Delete file? #{ENV['NO_DELETE_DB_FILE']}."
      client.destroy new_filename unless ENV['NO_DELETE_DB_FILE'] == '1'
    end
    Rails.logger.info "Attempting to save cursor #{cursor}"
    DropboxMetadata.new(cursor: cursor, created_at: Time.now).save
  end

  # <city_name>-<timestamp>
  def filename
    "#{city.downcase.gsub(/\s+/, '')}-#{DateTime.now.strftime('%Y%m%d_%H%M%S')}"
  end

  def client
    @client ||= DropboxClient.new(Rails.application.config.dropbox_token)
  end

  def city
    @city
  end
end
