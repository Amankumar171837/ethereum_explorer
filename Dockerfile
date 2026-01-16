# syntax=docker/dockerfile:1
FROM ruby:3.2.0-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    default-libmysqlclient-dev \
    git \
    curl \
    pkg-config \
    libsecp256k1-dev \
    autoconf \
    automake \
    libtool && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /app

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development test" \
    BUNDLE_DEPLOYMENT="1"

COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.4.10 && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bin/bundle

COPY . .

RUN bundle exec bootsnap precompile --gemfile app/ lib/

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
