FROM ruby:2.5-slim
LABEL maintainer="Micheal Waltz <ecliptik@gmail.com>"

#Set timezone to US/Pacific
RUN cp /usr/share/zoneinfo/US/Pacific /etc/localtime

#Setup environment and copy contents
WORKDIR /app
COPY . .

#Run ruby script
ENTRYPOINT [ "ruby", "/app/walt-grover.rb" ]