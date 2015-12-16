require 'dropbox_sdk'
require 'tempfile'

##
# Prep data and persist in dropbox
module DropboxPersistence
  extend ActiveSupport::Concern

  def save_to_dropbox(data)
    save_file(data)
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
