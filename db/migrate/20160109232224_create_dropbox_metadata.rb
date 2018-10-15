# frozen_string_literal: true

class CreateDropboxMetadata < ActiveRecord::Migration[5.1]
  def change
    create_table :dropbox_metadata do |t|
      t.string :cursor, null: false
      t.datetime :created_at, null: false
    end
  end
end
