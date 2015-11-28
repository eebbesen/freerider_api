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
`$ git push heroku master && heroku run rake db:migrate && heroku restart`

## Jobs
### poll_and_persist_vehicles
This rake task gets all vehicles for a city and persists the vehicle/location.

`rake poll_and_persist_vehicles`

I have it set up as a Heroku scheduled job.

