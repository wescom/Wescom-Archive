class StoryTopic < ActiveRecord::Base
  belongs_to :story
  belongs_to :topic
end
