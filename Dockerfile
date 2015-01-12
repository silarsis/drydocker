FROM ruby:2.2.0
ADD . /loop
WORKDIR /loop
RUN bundle install
RUN bundle exec rspec spec
RUN bundle exec rake build
RUN bundle exec rake install
WORKDIR /app
