class StoryImage < ActiveRecord::Base
  belongs_to :story
  
  has_attached_file :image, 
      :styles => { 
        :thumb  => "100x100>",
        :medium => "200x200>",
        :large => "400x400>"
      },
      :default_url => '/images/no-image.jpg'

end
