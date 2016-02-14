require 'dropbox_sdk'
require 'tempfile'
require 'mixpanel-ruby'

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
    delta = client.delta
    filenames = delta['entries'].each.map do |record|
      record[0].gsub(%r{^/}, '')
    end
    filenames
  end

  def get_file_data(filename)
    start = DateTime.now
    file = client.get_file filename
    data = file.gsub(%r{=>}, ':')
    ActiveSupport::JSON.decode(data)
  rescue DropboxError => e
    Rails.logger.warn "get_file_data for #{filename} failed after #{DateTime.now.to_time - start.to_time} seconds with #{e.class}:\n #{e.message}\n"
    unless e.message =~ /^File has been deleted/
      @client = nil
      retry
    end
    []
  end

  def read_from_dropbox
    mp_tracker = Mixpanel::Tracker.new ENV['MIXPANEL_TOKEN']
    new_files.each do |new_filename|
      mp_tracker.track '1', "Start parsing #{new_filename}"  
      VehicleLocation.transaction do
        get_file_data(new_filename).each do |vl|
          VehicleLocation.from_json(vl.merge({filename: new_filename})).save!
        end
      end
      begin
        client.file_delete new_filename
      rescue DropboxError => e
        Rails.logger.warn "#{e.class}:\n#{e.message}"
      end
    end
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
