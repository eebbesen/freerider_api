require "#{Rails.root}/app/controllers/concerns/dropbox_persistence.rb"

include DropboxPersistence

namespace :dropbox_test do
  desc 'save content to dropbox then delete it'
  task :save_delete, [:loc] => :environment do
    f = DropboxPersistence.save_to_dropbox "test content from #{Time.now}"
    raise RuntimeException 'save error' unless f
    puts "saved #{f}"

    d = DropboxPersistence.delete_from_dropbox f
    raise RuntimeException 'deletion error' unless d.name
    puts "#{d.name} deleted"
  end
end
