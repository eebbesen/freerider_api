source 'https://rubygems.org'

gem 'rails', '4.2.4'
gem 'rails-api'

gem 'caruby2go'
gem 'pg'
# gem 'sidekiq'

group :production do
  gem 'newrelic_rpm'
end

# should be in dev/test but problems when not
gem 'spring'

# dev/test

gem 'shoulda', group: :test

group :test, :development do
  gem 'byebug'
  gem 'sqlite3'
  gem 'rubocop'
  gem 'simplecov'
end
