#!/usr/bin/env ruby
# encoding: utf-8
#Ruby app to read Spotify current track and update Slack status

require 'net/http'
require 'json'
require 'uri'
require "base64"

#Require for url encoding
require "erb"
include ERB::Util

#ENV Vars Required
#CLIENT_ID
#CLIENT_SECRET
#REFRESH_TOKEN
#SLACK_PERSONAL_TOKEN
#DEFAULT_STATUS
#DEFAULT_EMOJI
#MUSIC_EMOJI

# Set slack status using legacy api
# https://api.slack.com/docs/presence-and-status
def set_status(status, emoji)
  # Read personal slack token from environment
  status_json = "{\"status_text\": \"#{status}\", \"status_emoji\": \"#{emoji}\"}"
  encoded = url_encode(status_json)

  uri = URI.parse("https://slack.com/api/users.profile.set")
  request = Net::HTTP::Post.new(uri)

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    request.body = "token=#{ENV["SLACK_PERSONAL_TOKEN"]}&profile=#{encoded}"
    http.request(request)
  end

  #Outpu result of slack status update
  case response
  when  Net::HTTPSuccess
    puts "Successfuly updated Slack"
    puts "status: #{status}"
    puts "emoji: #{emoji}"
    puts "response code: #{response.code}"
    puts "response message: #{response.message}"
  else
    puts "Error updating Slack"
    puts "response code: #{response.code}"
    puts "response message: #{response.message}"
  end
end

#Get refresh token
#Requires using the `app.rb` in this repository to get refresh token, see README.md
def refresh(refresh_token)
  #Base64 encode client id/secret
  base64client = Base64.strict_encode64("#{ENV["CLIENT_ID"]}:#{ENV["CLIENT_SECRET"]}")

  uri = URI.parse("https://accounts.spotify.com/api/token")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Basic #{base64client}"
  request.set_form_data(
    "grant_type" => "refresh_token",
    "refresh_token" => "#{refresh_token}",
  )

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  tokens = JSON.parse(response.body)

  #Return newly generated OAuth token
  return tokens['access_token']
end

#Get current spotify track using OAUTH token
#see https://developer.spotify.com/console/get-users-currently-playing-track/?market= to generate TOKEN
def current_spotify_track(access_token)

  uri = URI.parse("https://api.spotify.com/v1/me/player/currently-playing")
  request = Net::HTTP::Get.new(uri)
  request["Authorization"] = "Bearer #{access_token}"

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  #Only parse json if a 200 response, otherwise set to default status
  case response.code
  when "200"
    #Return current track json blob
    current_track_json = JSON.parse(response.body)
    artist = current_track_json["item"]["album"]["artists"][0]["name"]
    track = current_track_json["item"]["name"]

    #Build current_track
    current_track = "#{artist} - #{track}"
    emoji = ENV["MUSIC_EMOJI"]
  else
    #Default status if nothing is playing
    current_track = ENV["DEFAULT_STATUS"]
    emoji = ENV["DEFAULT_EMOJI"]
  end

  return current_track,emoji
end

#Run endlessly checking track every 5 minutes and setting status
#TODO: Probably set some type of check to not update status if track hasn't changed
begin
  #Set initial refresh token from env var
  refresh_token = ENV["REFRESH_TOKEN"]

  puts '[' + Time.now.strftime('%b %d %T.%2N') + '] Starting up...'
  puts "-------------------------"
  while true
    #Generate a new OAuth token every time a track is fetched in order to avoid timeouts
    access_token = refresh(refresh_token)

    #Build status
    status,emoji = current_spotify_track(access_token)

    #Update slack status
    set_status(status, emoji)

    #Sleep for 3 minutes
    sleepTime = 180
    puts "Sleeping for #{sleepTime} seconds..."
    puts "-------------------------"
    sleep(sleepTime)
  end
end
