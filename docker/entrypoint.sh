#!/bin/sh

set -e

rm -f /app/tmp/pids/server.pid

bundle install
bundle exec rake db:create db:migrate rswag:specs:swaggerize
bundle exec "$@"
