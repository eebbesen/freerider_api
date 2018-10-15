source 'https://rubygems.org'

gem 'rails', '5.2'
# gem 'rails-api'

gem 'caruby2go'
gem 'pg'
gem 'dropbox_api'

group :production do
  gem 'newrelic_rpm'
end

# should be in dev/test but problems when not
gem 'spring'

gem 'minitest-ci', git: 'https://github.com/circleci/minitest-ci.git'

# dev/test
gem 'tzinfo-data'
# gem 'shoulda', group: :test
# gem 'shoulda-matchers', group: :test
gem 'rails-controller-testing', group: :test

group :test, :development do
  gem 'byebug'
  gem 'minitest-reporters'
  gem 'rubocop'
  gem 'simplecov'
  gem 'sqlite3'
  gem 'bundle-audit'
end
