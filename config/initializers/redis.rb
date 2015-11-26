if !Rails.env.test?
  uri = URI.parse(ENV['REDISTOGO_URL'])
  REDIS = Redis.new(url: uri)
else
  REDIS = Redis.new
end
