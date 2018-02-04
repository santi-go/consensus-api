FROM ruby:2.4.2

WORKDIR /api
COPY . /api

RUN bundle install
