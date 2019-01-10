#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-2.5.1@wescomarchive

echo "$(date +%m/%d/%y\ %T)"
cd /u/apps/wescomarchive/current
bundle install>>/tmp/null

echo "Import Daily PDF Pages"
bundle exec rake wescom:pdf_import RAILS_ENV=production

echo "$(date +%m/%d/%y\ %T)"
