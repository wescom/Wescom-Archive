#!/usr/bin/env bash

#
# Script to import Google PDF pages
#   ie. google_pdf_import.sh <number of records to import>
#   If the parameter is not included, it is assumed to only import one record
#

# load rvm ruby
source /usr/local/rvm/environments/ruby-1.9.3-p194

echo "$(date +%m/%d/%y\ %T)"
cd /u/apps/wescomarchive/current
bundle install>>/tmp/null

echo "Import Google PDF Files"

if [ -z "$1" ]
then
	bundle exec rake wescom:import_google_pdf[1] RAILS_ENV=production
else
	bundle exec rake wescom:import_google_pdf[$1] RAILS_ENV=production
fi