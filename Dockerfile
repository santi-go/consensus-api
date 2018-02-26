FROM ruby:2.4.2

ENV API_PATH /consensus/api
WORKDIR $API_PATH
ADD . $API_PATH

CMD bundle install && rerun --background -- rackup --port 80 -o 0.0.0.0

EXPOSE 80
