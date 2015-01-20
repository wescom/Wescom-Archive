# Load the rails application
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Wescomarchive::Application.initialize!

#Date::DATE_FORMATS.merge!(:default => "%m/%d/%Y")