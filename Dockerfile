FROM --platform=linux/amd64 ruby:3.1.0

WORKDIR /usr/src/app

RUN apt-get update -qq && \
    apt-get install -y default-libmysqlclient-dev build-essential libpq-dev redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile* ./
COPY init.sql /db/
COPY config/sidekiq.yml ./config/


RUN bundle install

COPY . .
CMD ["rails", "server", "-b", "0.0.0.0"]
