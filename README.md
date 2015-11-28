[![Circle CI](https://circleci.com/gh/eebbesen/freerider_api.svg?style=shield)](https://circleci.com/gh/eebbesen/freerider_api)

# Freerider API
## System dependencies
* [caruby2go gem](https://github.com/eebbesen/caruby2go)
* Ruby 2.2.0

## Configuration
I'm including Heroku and Heroku add-on information here, but you can deploy where you'd like :).

Config variables to set in deployment app or cofig/environments/development.rb
  `ENV['CONSUMER_KEY'] = '<your_car2go_consumer_key>'`
  `ENV['NEW_RELIC_LICENSE_KEY'] = '<your_new_relic_license_key>'`

### Database initialization

  `rake db:migrate`

## Tests

  `rake test`


## Deployment instructions
### Heroku
I have a rake task which will push, migrate, restart and (as a validation) run poll_and_persist_vehicles

`rake heroku:deploy_and_run`

## Jobs
### `poll_and_persist_vehicles`
This task polls for and persists the vehicle/locations for all cities.

`rake poll_and_persist_vehicles`

I have it set up as a Heroku scheduled job.

## `locations`
This task returns the URI-ready city names where Car2Go operates

`rake locations`
