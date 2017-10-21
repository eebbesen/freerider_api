# frozen_string_literal: true

require "#{Rails.root}/app/controllers/concerns/dropbox_persistence.rb"

include DropboxPersistence

namespace :dropbox_test do
  desc 'save content to dropbox then delete it'
  task save_delete: :environment do
    f = DropboxPersistence.save_to_dropbox '[{"address"=>"W 4th St 90, 55102 Saint Paul", "coordinates"=>[-93.097112, 44.944025, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>36, "interior"=>"GOOD", "name"=>"AB5102", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME000"}, {"address"=>"Marshal Ave 1831, 55104 Saint Paul", "coordinates"=>[-93.177645, 44.949533, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>66, "interior"=>"GOOD", "name"=>"AB5104", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME001"}, {"address"=>"Ford Pkway 1974, 55116 Saint Paul", "coordinates"=>[-93.183036, 44.917769, 0], "engineType"=>"CE", "exterior"=>"GOOD", "fuel"=>18, "interior"=>"GOOD", "name"=>"AB7740", "smartPhoneRequired"=>false, "vin"=>"HAPPYGOFUNTIME002"}]'
    raise RuntimeError 'save error' unless f
    puts "saved #{f}"

    d = DropboxPersistence.send(:get_file_data, f)
    raise RuntimeError 'download error' unless d

    r = DropboxPersistence.delete_from_dropbox f
    raise RuntimeError 'deletion error' unless r.name
    puts "#{r.name} deleted"
  end

  desc 'list files'
  task list: :environment do
    files = DropboxPersistence.send(:new_filenames)
    files.each do |file|
      puts file
    end
    puts "there are #{files.size} files"
  end
end
