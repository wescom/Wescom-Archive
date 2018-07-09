#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-1.9.3-p194@rails-3.2.11

echo "$(date +%m/%d/%y\ %T)"
cd /u/apps/wescomarchive/current
bundle install>>/tmp/null

echo "Import Daily Stories"
bundle exec rake wescom:dti_import RAILS_ENV=production
bundle exec rake wescom:cloud_dti_import RAILS_ENV=production

# force all imported images to new owner, otherwise web process cannot modify/delete
#find /WescomArchive/db_images/1* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;
#find /WescomArchive/db_images/2* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;
#find /WescomArchive/db_images/3* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;
#find /WescomArchive/db_images/4* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;
#find /WescomArchive/db_images/5* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;
#find /WescomArchive/db_images/6* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;
#find /WescomArchive/db_images/7* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;
#find /WescomArchive/db_images/8* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;
#find /WescomArchive/db_images/9* -mtime -1 -exec chown -hR shoffmann:shoffmann {} \;

echo "Import Daily PDF Pages"
bundle exec rake wescom:pdf_import RAILS_ENV=production

echo "$(date +%m/%d/%y\ %T)"
