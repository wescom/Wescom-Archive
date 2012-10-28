#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-1.9.3-p194@rails-3.2.3

echo "$(date +%m/%d/%y\ %T)"
cd /u/apps/wescomarchive/current
bundle install

rake wescom:dti_import RAILS_EN=production
