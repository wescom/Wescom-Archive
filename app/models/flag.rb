class Flag < ActiveRecord::Base
    has_and_belongs_to_many :stories
    has_and_belongs_to_many :story_images
end
