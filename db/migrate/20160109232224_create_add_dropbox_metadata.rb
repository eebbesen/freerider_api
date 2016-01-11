class CreateAddDropboxMetadata < ActiveRecord::Migration
  def change
    create_table :add_dropbox_metadata do |t|
      t.string :cursor, null: false

      t.timestamps null: false
    end
  end
end
