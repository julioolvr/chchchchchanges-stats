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

get '/stats' do
  content_type :json
  redis.hgetall('stats').to_json
end

post '/stats' do
  water_raised = params["waterRaised"]
  ice_melted = params["iceMelted"]
  animals_killed = params["animalsKilled"]
  years_lost = params["yearsLost"]

  redis.hincrby 'stats', 'waterRaised', water_raised
  redis.hincrby 'stats', 'iceMelted', ice_melted
  redis.hincrby 'stats', 'animalsKilled', animals_killed
  redis.hincrby 'stats', 'yearsLost', years_lost

  status 200
end