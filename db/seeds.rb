# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

puts 'Creating DEFAULT USER:'
user = User.find_or_create_by_email :login => ENV['LOGIN']
user.role = 'Admin'
user.save
puts 'user: ' << user.name
puts ''

puts 'Creating SITE SETTINGS RECORD'
site_settings = SiteSettings.find_or_create_by_id({:id => 1}, :without_protection => true)
site_settings.show_delete_button = 0
site_settings.site_announcement = ''
site_settings.show_site_announcement = 0
site_settings.save
puts ''
