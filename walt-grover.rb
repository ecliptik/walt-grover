#!/usr/bin/env ruby
# encoding: utf-8

require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'cgi'
require 'httparty'

# Set slack status using legacy api
# https://api.slack.com/docs/presence-and-status
def set_status(message, emoji)
  # Read personal slack token from environment
  slack_token = ENV["SLACK_PERSONAL_TOKEN"]
  status_json = "{\"status_text\": \"#{message}\", \"status_emoji\": \"#{emoji}\"}"
  encoded = CGI.escape(status_json)
  data = "token=#{slack_token}&profile=#{encoded}"
  uri = URI.parse("https://slack.com/api/users.profile.set")
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true
  req = Net::HTTP::Post.new(uri.path)
  req.body = data
  res = https.request(req)
end

#Get current spotify track using OAUTH token
#see https://developer.spotify.com/console/get-users-currently-playing-track/?market= to generate TOKEN
#TODO: Generate refresh token using Spotify Authoriziation workflow/callback.
def current_spotify_track()
  access_token = ENV["SPOTIFY_ACCESS_TOKEN"]

  uri = URI.parse("https://api.spotify.com/v1/me/player/currently-playing")
  https = Net::HTTP.new(uri.host,uri.port)
  https.use_ssl = true
  req = Net::HTTP::Get.new(uri.path)
  req['Authorization'] = "Bearer #{access_token}"
  res = https.request(req)

  return res.body
end


#Run endlessly checking track every 5 minutes and setting status
#TODO: Probably set some type of check to not update status if track hasn't changed
begin
  puts '[' + Time.now.strftime('%b %d %T.%2N') + '] Starting up...'
  while true

    json = JSON.parse(current_spotify_track)
    artist = json["item"]["album"]["artists"][0]["name"]
    track = json["item"]["name"]

    #Build status
    status = "#{artist} - #{track}"

    #Update slack status
    puts "Setting status: #{status}"
    emoji = ":musical_note:"
    set_status(status, emoji)

    #Sleep for 5 minutes
    sleepTime = 300
    puts "Sleeping for #{sleepTime} seconds..."
    sleep(sleepTime)
  end
end
