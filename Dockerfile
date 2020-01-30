FROM ruby:2.7-slim AS base
LABEL maintainer="Micheal Waltz <docker@accounts.ecliptik.com>"

#Setup environment and copy contents
WORKDIR /usr/src/app
COPY ./walt-grover.rb .

#App command
CMD [ "/usr/src/app//walt-grover.rb" ]
