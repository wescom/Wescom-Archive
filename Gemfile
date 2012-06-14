source 'http://rubygems.org'

gem 'rails', '3.1.0'
gem 'mysql2'
gem 'mysql'
gem 'dti_nitf'
gem 'sunspot'
gem 'sunspot_rails'
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
  gem 'sass-rails', " ~> 3.1.0"
  gem 'coffee-rails', " ~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

group :development, :test do
  gem "capistrano"
	gem 'sunspot_solr'
	#  http://rails.vandenabeele.com/blog/2011/12/21/installing-ruby-debug19-with-ruby-1-dot-9-3-on-rvm/
end

group :production do
  gem "therubyracer"
end
