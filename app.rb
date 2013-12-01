require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'redis'

configure do
  enable :cross_origin
end

def redis
  @redis ||= begin
    uri = URI.parse(ENV["REDISTOGO_URL"])
    Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end
end

def valid_stats(water_raised, ice_melted, animals_killed, years_lost)
  water_raised >= 0 && ice_melted >= 0 && animals_killed >= 0 && years_lost >= 0 && years_lost <= 1800
end

get '/stats' do
  content_type :json
  redis.hgetall('stats').to_json
end

post '/stats' do
  water_raised = (params["waterRaised"].to_f * 10).to_i
  ice_melted = (params["iceMelted"].to_f * 10).to_i
  animals_killed = params["animalsKilled"].to_i
  years_lost = params["yearsLost"].to_i

  if valid_stats(water_raised, ice_melted, animals_killed, years_lost)
    redis.hincrby 'stats', 'waterRaised', water_raised
    redis.hincrby 'stats', 'iceMelted', ice_melted
    redis.hincrby 'stats', 'animalsKilled', animals_killed
    redis.hincrby 'stats', 'yearsLost', years_lost

    status 200
  else
    status 403
  end

end