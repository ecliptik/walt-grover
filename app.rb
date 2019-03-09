require "sinatra"
require "net/http"
require "uri"
require "base64"
require "slim"

#Require for url encoding
require "erb"
include ERB::Util

#Required ENV vars generated from https://developer.spotify.com/
#CLIENT_ID
#CLIENT_SECRET

client_id = "#{ENV["CLIENT_ID"]}"
client_secret = "#{ENV["CLIENT_SECRET"]}"
scope = "user-read-currently-playing"
callback_uri = "http://localhost:9292/callback"
callback_uri_enc = url_encode(callback_uri)

#Create link to log into Spotify and being authorization workflow
get "/" do
  spotify_auth = "https://accounts.spotify.com/authorize?client_id=#{client_id}&response_type=code&redirect_uri=#{callback_uri_enc}&scope=#{scope}"
  "<a href=\"#{spotify_auth}\">login with spotify</a>"
end

#Callback url to send authorization response back to
#returns a code that's then sent to the api/token endpoint to get
#an access_token and refresh_token
get "/callback" do
  #Base64 encode client id/secret
  base64client = Base64.strict_encode64("#{client_id}:#{client_secret}")

  uri = URI.parse("https://accounts.spotify.com/api/token")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Basic #{base64client}"
  request.set_form_data(
    "code" => "#{params[:code]}",
    "grant_type" => "authorization_code",
    "redirect_uri" => "#{callback_uri}",
  )

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  codes = JSON.parse(response.body)
  @access_token = codes['access_token']
  @refresh_token = codes['refresh_token']

  #Render simple slim template
  slim :index
end

__END__

@@layout
doctype html
html
  head
    meta charset="utf-8"
    title Spotify Auth Callback
  body
    == yield

@@index
p acccess_token: #{@access_token}
p refresh_token: #{@refresh_token}
