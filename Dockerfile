FROM ruby:2.4.2

WORKDIR /api
COPY . /api

CMD bundle install --without development test && bundle exec rake &
