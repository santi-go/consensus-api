FROM ruby:2.4.2

WORKDIR /opt/consensus_api

COPY Gemfile* /opt/consensus_api/
RUN bundle install

COPY . /opt/consensus_api

EXPOSE 4567

CMD ["bundle", "exec", "rake", "start"]
