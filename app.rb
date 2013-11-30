require 'sinatra'
require 'json'
require 'redis'

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

  redis.hincrby 'stats', 'waterRaised', water_raised
  redis.hincrby 'stats', 'iceMelted', ice_melted
  redis.hincrby 'stats', 'animalsKilled', animals_killed

  status 200
end