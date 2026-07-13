ARG RUBY_VERSION=3.3.1
FROM ruby:${RUBY_VERSION}-slim AS base

# 1. Base Environment Config
ENV RAILS_ENV=production \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    PORT=3000

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 2. Build Stage (Installs gems, then gets discarded)
FROM base AS build

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# 3. Final Production Stage (The safe, lightweight image for deployment)
FROM base AS production

# Only install runtime dependencies (PostgreSQL client)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libpq-dev postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives && \
    useradd rails --create-home --shell /bin/bash

# Copy code and gems from the build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN chown -R rails:rails /rails /usr/local/bundle
USER rails

EXPOSE 3000
CMD ["bash", "-lc", "rm -f tmp/pids/server.pid && bin/rails db:prepare && bundle exec puma -C config/puma.rb"]
