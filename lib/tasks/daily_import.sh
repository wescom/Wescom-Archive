#!/bin/bash

cd /u/apps/wescomarchive/current
rvm ruby-1.9.3-p194
#bundle install

rake wescom:dti_import RAILS_ENV=production