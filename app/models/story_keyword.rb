class StoryKeyword < ActiveRecord::Base
  belongs_to :story
  belongs_to :keyword
end
