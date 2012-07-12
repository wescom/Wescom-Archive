class StoryImage < ActiveRecord::Base
  belongs_to :story
  
  has_attached_file :image, 
      :styles => { 
        :thumb  => ["100x100>",:jpg],
        :medium => ["200x200>",:jpg],
        :large => ["400x400>",:jpg]
      },
      :url => "/system/:attachment/:id/:style_:basename.:extension",  
      :path => ":rails_root/public/system/:attachment/:id/:style_:basename.:extension",
      :default_url => '/images/no-image.jpg'

#  before_post_process :is_image?
  def is_image?
    !(image_content_type =~ /^image.*/).nil?
  end


  class << self
    def published
      where(:publish_status => 'Published')
    end
  end
  
  class << self
    def attached
      where(:publish_status => 'Attached')
    end
  end

end
