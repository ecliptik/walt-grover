FROM ruby:2.6-slim AS base
LABEL maintainer="Micheal Waltz <docker@accounts.ecliptik.com>"

#Setup environment and copy contents
WORKDIR /app
COPY . .

#App command
ENTRYPOINT ["ruby"]
CMD [ "/app/walt-grover.rb" ]
