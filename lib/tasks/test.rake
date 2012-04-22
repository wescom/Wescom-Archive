desc "Import all the SII stories"
task :test_story => :environment do

stories = Story.find(:all)
stories.each do |story|
  puts story.headline
end
end