require 'test_helper'

class DropboxMetadataTest < ActiveSupport::TestCase
  should validate_presence_of :cursor
  should validate_presence_of :created_at
end
