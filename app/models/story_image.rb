class StoryImage < ActiveRecord::Base
  belongs_to :story
  
  has_attached_file :image, 
      :styles => { 
        :large => ["500x500>",:jpg]
      },
      :url => "/system/db_images/:id/:style_:basename.:extension",  
      :path => ":rails_root/public/system/db_images/:id/:style_:basename.:extension",
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

  class << self
    def pagepdf
      where(:publish_status => 'PagePDF')
    end
  end

end
