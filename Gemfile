source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
gem 'mysql2' 

gem 'bootstrap', '= 4.0.0'
gem 'font-awesome-sass', '~> 4.7.0'
gem 'bootstrap-datepicker-rails'

gem 'progress_bar'
gem 'will_paginate'
gem 'will_paginate-bootstrap'

gem "paperclip", "~> 6.0.0"
gem "mini_magick"
gem 'mini_exiftool'
gem 'yomu'
gem 'double-bag-ftps'
gem 'crack'

#gem 'activerecord-mysql-adapter'
#gem 'net-ssh', '< 2.8.0'
#gem 'dti_nitf'

gem "figaro", ">= 0.5.3"  # use for environment variables
gem 'nokogiri'
gem 'premailer-rails' # use for css styling in mailer
gem 'chronic'

# Fulltext search indexing
gem 'sunspot_rails'
gem 'sunspot_solr' # optional pre-packaged Solr distribution for use in development

# Authentication
gem 'adauth'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Puma as the app server
#gem 'puma', '~> 3.0'
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
#gem 'therubyracer', platforms: :ruby
gem 'mini_racer'

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.3.3'
end

# Use Capistrano for deployment
group :development do
    gem "capistrano", "~> 3.10", require: false
    gem "capistrano-rails", "~> 1.3", require: false
    gem 'capistrano-rvm', require: false
    gem 'capistrano-bundler', require: false
    gem 'capistrano3-puma', require: false
end
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
