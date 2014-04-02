# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"

Faye::WebSocket.load_adapter('thin')

env = ENV["RAILS_ENV"] || "development"
file = File.expand_path("../config/private_pub.yml", __FILE__)
PrivatePub.load_config(file, env)

faye = PrivatePub.faye_app

if env == 'development'
  faye.bind(:publish) do |client_id, channel, data|
    puts "publish #{client_id} #{channel} #{data.inspect}"
  end

  faye.bind(:subscribe) do |client_id, channel|
    puts "subscribe #{client_id} #{channel}"
  end
end

run faye
