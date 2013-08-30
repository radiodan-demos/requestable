#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'radiodan'
require 'radiodan/sinatra'

class WebApp < Radiodan::Sinatra
  get '/' do
    'hello'
  end
end

radio = Radiodan.new do |builder|
  builder.log      STDOUT
  builder.adapter  :MPD, :host => 'localhost', :port => 6600
  builder.use :web_server, WebApp
  builder.playlist Radiodan::Playlist.new
end

radio.start

