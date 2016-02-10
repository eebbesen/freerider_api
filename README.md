[![Circle CI](https://circleci.com/gh/eebbesen/freerider_api.svg?style=shield)](https://circleci.com/gh/eebbesen/freerider_api)

# Freerider API
## System dependencies
* [caruby2go gem](https://github.com/eebbesen/caruby2go)
* Ruby 2.2.0

## Configuration
I'm including Heroku and Heroku add-on information here, but you can deploy where you'd like :).

Config variables to set in deployment app or cofig/environments/development.rb

    ENV['CONSUMER_KEY'] = '<your_car2go_consumer_key>'
    ENV['NEW_RELIC_LICENSE_KEY'] = '<your_new_relic_license_key>'
    ENV['DROPBOX_CLIENT_ACCESS_TOKEN'] = '<your_dropbox_access_token>'

### Database initialization

`rake db:migrate`

## Tests

`rake test`


## Deployment instructions
### Heroku
To run a rake task which will 
* push code to Heroku 
* run migrations on Heroku 
* restart the application on Heroku 
* run `poll_and_persist_vehicles['twincities']` against the Heroku instance (as a validation -- you should monitor the output) 

`rake heroku:deploy_and_run`

## Jobs
### `poll_and_dropbox_vehicles`
This task polls for and places one file per run per city in a dropbox location.

`rake poll_and_dropbox_vehicles`

Or for just one city

`rake poll_and_dropbox_vehicles['twincities']`

### `poll_and_persist_vehicles`
This task polls for and persists the vehicle/locations for all cities into the database.

`rake poll_and_persist_vehicles`

Or for just one city

`rake poll_and_persist_vehicles['twincities']`

### `consume_dropbox_data`
This task persists Dropbox file data into a local database and (by default) deletes processed files from Dropbox
`RAILS_ENV=production bundle exec rake consume_dropbox_data`

If you wish _not_ to delete files from Dropbox

`export NO_DELETE_DB_FILE='1'`

## `locations`
This task returns the URI-ready city names where Car2Go operates

`rake locations`
