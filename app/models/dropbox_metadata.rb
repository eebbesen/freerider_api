class DropboxMetadata < ActiveRecord::Base
  validates_presence_of :cursor, :created_at
end
