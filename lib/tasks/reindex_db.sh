#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-1.9.3-p194

echo "$(date +%m/%d/%y\ %T)"
cd /u/apps/wescomarchive/current
bundle install>>/tmp/null

bundle exec rake sunspot:reindex RAILS_ENV=production
