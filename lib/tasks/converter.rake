# frozen_string_literal: true

require 'csv'

namespace :converter do
  desc 'add vehicle location time to csv'
  task :add_vehicle_location_time, [:csv] => :environment do |_t, args|
    CSV.open(args[:csv].gsub(/.csv/, "_#{Time.now.iso8601}.csv"), 'wb') do |csv|
      CSV.foreach(args[:csv]) do |row|
        # remove 'id' field
        row.shift
        if row.last =~ /\w+-\d{8}_\d{6}/
          row << VehicleLocation.extract_when_from_filename(row.last)
          csv << row
        elsif row.last == 'filename'
          row << 'when'
          csv << row
        else
          puts "Didn't get date from value '#{row.last}'"
        end
      end
    end
  end
end
