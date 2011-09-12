class Keyword < ActiveRecord::Base
  has_many :story_keywords
  has_many :stories, :through => :story_keywords
end
