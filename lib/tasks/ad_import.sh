#!/bin/bash

export PATH=/usr/local/rvm/gems/ruby-2.5.1@wescomarchive/bin:/usr/local/rvm/gems/ruby-2.5.1@global/bin:/usr/local/rvm/rubies/ruby-2.5.1/bin:/usr/local/rvm/gems/ruby-2.5.1@wescomarchive/bin:/usr/local/rvm/gems/ruby-2.5.1@global/bin:/usr/local/rvm/rubies/ruby-2.5.1/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

# load rvm ruby
source /usr/local/rvm/environments/ruby-2.5.1@wescomarchive

echo "$(date +%m/%d/%y\ %T)"
cd /u/apps/wescomarchive/current
bundle install>>/tmp/null

echo "Import current months Ads"
bundle exec rake wescom:ad_import RAILS_ENV=production

echo "$(date +%m/%d/%y\ %T)"
