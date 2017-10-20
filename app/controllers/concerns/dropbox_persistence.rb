# frozen_string_literal: true

require 'dropbox_api'

##
# Prep data and persist in dropbox
# Retrieve data from dropbox
module DropboxPersistence
  extend ActiveSupport::Concern

  def save_to_dropbox(data)
    save_file data
  end

  def delete_from_dropbox(filename)
    client.delete filename
  rescue DropboxApi::Errors::BasicError => e
    Rails.logger.warn "#{e.class}:\n#{e.message}"
    false
  end

  private

  def save_file(data)
    fn = generate_filename
    client.upload(fn, data)
    Rails.logger.info "#{fn} saved to Dropbox"
    fn
  end

  def generate_filename
    ts = DateTime.now.strftime('%Y%m%d_%H%M%S')
    "/#{filename_prefix.downcase.gsub(/\s+/, '')}-#{ts}"
  end

  def new_filenames
    delta = client.delta
    filenames = delta['entries'].each.map do |record|
      record[0].gsub(%r{^/}, '')
    end
    filenames
  end

  def get_file_data(filename)
    start = DateTime.now
    file = client.get_file filename
    data = file.gsub(/=>/, ':')
    ActiveSupport::JSON.decode(data)
  rescue DropboxError, Errno::ETIMEDOUT => e
    Rails.logger.warn "get_file_data for #{filename} failed after #{DateTime.now.to_time - start.to_time} seconds with #{e.class}:\n #{e.message}\n"
    unless e.message =~ /^File has been deleted/
      @client = nil
      retry
    end
    []
  end

  def client
    @client ||= DropboxApi::Client.new(Rails.application.config.dropbox_data_token)
  end

  def filename_prefix
    @filename_prefix ||= 'default_filename_prefix'
  end
end
