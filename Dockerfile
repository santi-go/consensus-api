FROM ruby:2.4.2

WORKDIR /api
ADD . /api

RUN apt-get update && apt-get upgrade -y -q \
    && gem install bundle \
    && bundle install

CMD bundle exec rake
