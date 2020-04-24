#!/bin/bash

export PATH=/usr/local/rvm/gems/ruby-2.5.1@wescomarchive/bin:/usr/local/rvm/gems/ruby-2.5.1@global/bin:/usr/local/rvm/rubies/ruby-2.5.1/bin:/usr/local/rvm/gems/ruby-2.5.1@wescomarchive/bin:/usr/local/rvm/gems/ruby-2.5.1@global/bin:/usr/local/rvm/rubies/ruby-2.5.1/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

# load rvm ruby
source /usr/local/rvm/environments/ruby-2.5.1@wescomarchive

echo "$(date +%m/%d/%y\ %T)"
cd /u/apps/wescomarchive/current
bundle install>>/tmp/null

echo "Import Daily Stories"
#bundle exec rake wescom:dti_import RAILS_ENV=production
#bundle exec rake wescom:cloud_dti_import RAILS_ENV=production

# Update any changes to yesterday's stories and import any missing stories
bundle exec rake townnews:rss_import date=$(date -d "1 days ago" +%m/%d/%Y) RAILS_ENV=production

# Import today's stories. Any story with a startdate time after NOW will be excluded because it is not live yet.
bundle exec rake townnews:rss_import date=$(date +%m/%d/%Y) RAILS_ENV=production

echo "$(date +%m/%d/%y\ %T)"
