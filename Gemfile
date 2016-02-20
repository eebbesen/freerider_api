source 'https://rubygems.org'

gem 'rails', '4.2.4'
gem 'rails-api'

gem 'caruby2go'
gem 'pg'
gem 'dropbox-sdk'
# gem 'sidekiq'

group :production do
  gem 'newrelic_rpm'
end

# should be in dev/test but problems when not
gem 'spring'

gem 'minitest-ci', git: 'https://github.com/circleci/minitest-ci.git'

# dev/test
gem 'tzinfo-data'
gem 'shoulda', group: :test

group :test, :development do
  gem 'byebug'
  gem 'minitest-reporters'
  gem 'rubocop'
  gem 'simplecov'
  gem 'sqlite3'
end
