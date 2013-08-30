#!/usr/bin/env ruby
require 'bundler/setup'
require 'radiodan'
require 'mongo'
require 'uri'

class Requestable
  include Radiodan::Logging
  def initialize
    uri = URI(ENV['MONGODB'])
    db_name = uri.path.gsub(/^\//, '')
    collection_name = 'playlists'

    connection = Mongo::Connection.from_uri(uri.to_s)
    db = connection.db db_name
    @collection = db[collection_name] || db.create_collection(collection_name, {capped: true, size: 8000000})
  end

  def call(player)
    player.register_event :sync do |playlist|
      @collection.insert(:playlist => playlist.attributes, :time => Time.now.to_f * 1000)
    end

    EM::Synchrony.now_and_every(:minutes => 1) do
      track = player.search(:artist => 'Fugazi').sample
      player.playlist.tracks << track
      logger.info "Added #{track[:file]}"
    end
  end
end

radio = Radiodan.new do |builder|
  builder.log      STDOUT
  builder.adapter  :MPD, :host => 'localhost', :port => 6600
  builder.use      Requestable
  builder.playlist Radiodan::Playlist.new
end

radio.start

