# walt-grover
Automatically update Slack status with current Spotify track.

## Spotify Authentication

In order to access the Spotify API you must generate a proper OAuth token following the [Spotify Authorizataion Guide](https://developer.spotify.com/documentation/general/guides/authorization-guide/).

This repository containers a simple callback script to get a Refresh Token which is used in the `walt-grover.rb` script to continually generate a fresh OAuth token.

Before building and running the container, you must create a Spotify App on the developer dashboard,

- https://developer.spotify.com/

Copy the `Client ID` and `Client Secret` for the Spotify App as these are needed when running the container.

Set the `Redirect URIs` to `http://localhost:9292/callback` in the Spotify App settings, this must match exactly or the callback will not work.

## Generating Spotify Refresh Token Using Callback

The callback container is only needed once in order to generate a `refresh_token` and only needed unless the `refresh_token` has expired.

Build the callback image from `Dockerfile.callback`,

```
docker build -f Dockerfile.callback -t callback .
```

Run the callback on localhost on port 9292 passing the CLIENT_ID and CLIENT_SECRET generated previously,

```
docker run -it --rm -e CLIENT_ID=*YOURCLIENTID* -e CLIENT_SECRET=*YOURCLIENTSECRET* -p 9292:9292 callback
```

In a web borwser go to http://localhost:9292 and click the `login with spotify` link. Authenticate with Spotify and a page with an `access_token` and `refresh_token` will generate. The `refresh_token` is used when running the `waltgrover` container to update Slack status.

## Setting Slack Status to Current Spotify Track

Requires
- [Slack Personal API Token](https://api.slack.com/tokens)
- Spotify client_id and client_secret - generated from Spotify App Dashboard
- Spotify refresh_token - generated from callback container
- Default status, emoji, and music emoji to use

Update the `.env.example` file in this repository with your Spotify, Slack, and other configurations, and copy to `.env` for the container to use as it's configuration.

Example `.env` file,

```
CLIENT_ID=*YOURSPOTIFYCLIENTID*
CLIENT_SECRET=*YOURSPOTIFYCLIENTSECRET*
REFRESH_TOKEN=*YOURSPOTIFYREFRESHTOKEN*
SLACK_PERSONAL_TOKEN=*YOURSLACKTOKEN*
DEFAULT_STATUS="Nothing currently playing"
DEFAULT_EMOJI=":speech_balloon:"
MUSIC_EMOJI=":musical_note:"
```

Build the waltgrover image from `Dockerfile`,

```
docker build -t waltgrover .
```

Run the waltgrover container by passing a `.env` file with required configuration,

```
docker run -it --rm --env-file=.env waltgrover
```

The container queries the Spotify API and sets Slack status to the current playing track every 3 minutes, if nothing is playing, a default status and emoji are set based on the `DEFAULT_STATUS` and `DEFAULT_EMOJI` env vars.

Example container output,

```
[Mar 09 07:02:46.37] Starting up...
-------------------------
Successfuly updated Slack
status: Massive Attack - Unfinished Sympathy - 2012 Mix/Master
emoji: :musical_note:
response code: 200
response message: OK
Sleeping for 180 seconds...
-------------------------
Successfuly updated Slack
status: The Raconteurs - Salute Your Solution
emoji: :musical_note:
response code: 200
response message: OK
Sleeping for 180 seconds...
-------------------------
Successfuly updated Slack
status: The Rentals - My Head Is In The Sun
emoji: :musical_note:
response code: 200
response message: OK
Sleeping for 180 seconds...
-------------------------
Successfuly updated Slack
status: Nothing currently playing
emoji: :speech_balloon:
response code: 200
response message: OK
Sleeping for 180 seconds...
-------------------------
```
