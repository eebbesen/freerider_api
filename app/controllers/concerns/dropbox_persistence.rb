require 'dropbox_sdk'
require 'tempfile'

##
# Prep data and persist in dropbox
# Retrieve data from dropbox
module DropboxPersistence
  extend ActiveSupport::Concern

  def save_to_dropbox(data)
    save_file(data)
  end

  def read_from_dropbox
    file_data = new_files.inject({}) do |data, new_filename|
      data.merge(new_filename => get_file_data(new_filename))
    end
    Rails.logger.info "Attempting to save cursor #{cursor}"
    DropboxMetadata.new(cursor: cursor, created_at: Time.now).save
    file_data
  end

  def cursor
    @cursor
  end

  def cursor=(cursor)
    @cursor = cursor
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
    @cursor ||= DropboxMetadata.last.cursor
    delta = client.delta @cursor
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
