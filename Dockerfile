FROM ruby:3.2

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends docker.io \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /drydocker
COPY . .
RUN bundle install
RUN bundle exec rake build:gem
RUN bundle exec gem install pkg/drydocker*.gem

WORKDIR /app
CMD ["drydocker"]
