#!/usr/bin/env ruby
require 'bundler/setup'
require 'radiodan'
require 'mongo'
require 'uri'

class Requestable
  include Radiodan::Logging
  def initialize
    uri = URI(ENV['MONGODB'])
    db_name = uri.path.split('/').last

    connection = Mongo::Connection.from_uri(uri.to_s)
    @db = connection.db db_name
    @playlists = collection('playlists', :max => 1)
    @requests  = collection('requests',  :max => 50)
    @play
  end

  def call(player)
    player.register_event :sync do |playlist|
      @playlists.insert(:playlist => playlist.attributes, :time => Time.now.to_f * 1000)
    end

    tail = Mongo::Cursor.new(@requests, :tailable => true, :order => [['$natural', 1]])

    EM::Synchrony.now_and_every(0.5) do
      request = tail.next
      case
      when request.nil?
        next
      when !request.has_key?('string')
        next
      when (Time.now - request['timestamp']) > 60
        # a minute old is too old IMHO
        next
      else
        track = player.search(request['string']).sample

        next if track.nil?

        player.playlist.tracks << track
        logger.info "Added #{track[:file]}"
      end
    end
  end
  
  private
  def collection(collection_name, options={})
    options.merge!(:capped => true, :size => 8_000_000)
    @db[collection_name].count > 0 ? @db[collection_name] : @db.create_collection(collection_name, options)
  end
end

radio = Radiodan.new do |builder|
  builder.log      STDOUT
  builder.adapter  :MPD, :host => 'localhost', :port => 6600
  builder.use      Requestable
  builder.playlist Radiodan::Playlist.new
end

radio.start

