source 'http://rubygems.org'

gem 'rails', '3.2.11'
gem 'railties', '3.2.11'
gem 'mysql2'
gem 'mysql', '2.9.0'
gem 'activerecord-mysql-adapter'
gem 'dti_nitf'
gem 'sunspot'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'progress_bar'
gem 'will_paginate'
gem 'chronic'
gem 'mongrel', "1.2.0.pre2"
gem "paperclip", "~> 3.0"

gem 'unicorn'
gem 'capistrano'
gem 'rvm-capistrano'

# Authentication
gem "oauth"
gem "ruby-openid", :require => "openid"
gem "ruby-openid-apps-discovery", :git => "git://github.com/skrat/ruby-openid-apps-discovery.git", :require => "gapps_openid"
gem "rack-openid", :require => "rack/openid"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'

group :development, :test do
  gem "capistrano"
	#  http://rails.vandenabeele.com/blog/2011/12/21/installing-ruby-debug19-with-ruby-1-dot-9-3-on-rvm/
end

group :production do
  gem "therubyracer"
end
