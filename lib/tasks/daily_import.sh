#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-1.9.3-p194@rails-3.2.3

echo "$(date +%m/%d/%y\ %T)"
cd /u/apps/wescomarchive/current
bundle install>>/tmp/null

rake wescom:dti_import RAILS_ENV=production

find /WescomArchive/db_images/* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;

echo "$(date +%m/%d/%y\ %T)"
