[![Circle CI](https://circleci.com/gh/eebbesen/freerider_api.svg?style=shield)](https://circleci.com/gh/eebbesen/freerider_api)

# Freerider API

This project will read vehicle location data from Car2Go and persist it to
* a file in Dropbox
* a relational database like PostgreSQL

This project will read Car2Go vehicle location data from a Dropbox file and persist it to a relational database like PostgreSQL.

The reason for offering Dropbox as an intermediary is to allow me to avoid paying for a hosted PostgreSQL instance :).

Note that times are by default in UTC.

## System dependencies
* Ruby 2.2.0

## Configuration
I'm including Heroku and Heroku add-on information here, but you can deploy where you'd like.

Config variables to set in deployment app or cofig/environments/development.rb

    ENV['CONSUMER_KEY'] = '<your_car2go_consumer_key>'
    ENV['NEW_RELIC_LICENSE_KEY'] = '<your_new_relic_license_key>'
    ENV['DROPBOX_OAUTH_BEARER'] = '<your_dropbox_access_token>'

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
This task persists Dropbox file data into a local database and deletes processed files from Dropbox

    RAILS_ENV=production bundle exec rake consume_dropbox_data

I `cron` it:

    42 * * * * /bin/bash -l -c 'cd /home/username/projects/freerider_api && rvm use ruby-2.2.2 && bundle install \
    && RAILS_ENV=production bundle exec rake consume_dropbox_data'

### `converter:add_vehicle_location_time`
The filename column gives you an idea of when a vehicle location was recorded, but that doesn't work in the context of tools like Carto.  This task adds a timestamp on the end of each row in a new CSV it creates from the one you pass in

`rake converter:add_vehicle_location_time['<csv_to_convert>']`

## `locations`
This task returns the URI-ready city names where Car2Go operates

`rake locations`

### `create_map`
This task will take the last five days' location data for a given city and create a CSV of the data in Dropbox

`rake create_map['twincities']`
