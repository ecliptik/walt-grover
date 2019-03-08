# walt-grover
Automatically update Slack status with current Spotify track.

# Spotify Authentication

In order to access the Spotify API you must generate a proper OAuth token following the [Spotify Authorizataion Guide](https://developer.spotify.com/documentation/general/guides/authorization-guide/).

This connector currently doesn't generate an OAuth token (todo) and right now only works by generating an OAuth token using the [Developer Console](https://developer.spotify.com/console/get-users-currently-playing-track/?market=). This OAuth token has a TTL of 1 hour and must be regenerated after.

# Building

Build the container

```
docker build -t waltgrover .
```

# Running

Requires and valid Spotify OAuth token and [Slack Personal API Token](https://api.slack.com/tokens).

Run the container by passing these tokens in env vars `SPOTIFY_ACCESS_TOKEN` and `SLACK_PERSONAL_TOKEN`,

Example,

```
docker run -it --rm -e SPOTIFY_ACCESS_TOKEN=$OAUTHTOKEN -e SLACK_PERSONAL_TOKEN=$SLACKTOKEN waltgrover
```
