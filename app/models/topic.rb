class Topic < ActiveRecord::Base
  has_many :story_topics
  has_many :stories, :through => :story_topics
end
