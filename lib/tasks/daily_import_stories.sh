#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-2.5.1@wescomarchive

echo "$(date +%m/%d/%y\ %T)"
cd /u/apps/wescomarchive/current
bundle install>>/tmp/null

echo "Import Daily Stories"
#bundle exec rake wescom:dti_import RAILS_ENV=production
bundle exec rake wescom:cloud_dti_import RAILS_ENV=production

echo "$(date +%m/%d/%y\ %T)"
