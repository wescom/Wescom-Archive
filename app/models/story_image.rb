class StoryImage < ActiveRecord::Base
  belongs_to :story
  
  has_attached_file :image, 
      :styles => { 
        :large => ["500x500>",:jpg]
      },
      :url => "/system/db_images/:id/:style_:basename.:extension",  
      :path => ":rails_root/public/system/db_images/:id/:style_:basename.:extension",
      :default_url => '/images/no-image.jpg'

  searchable :auto_index => true, :auto_remove => true do
    # Search fields
    text :media_printcaption
    text :media_originalcaption
    text :media_printproducer, :default_boost => 2.0
    text :media_byline, :default_boost => 2.0
    text :media_name, :default_boost => 3.0
    text :media_project_group, :default_boost => 3.0
    text :publish_status

    # Sort fields - must use 'string' instead of 'text'
    string :story_publication_name do
      story.publication_name if story.publication_name
    end
    string :story_section_name do
      story.section_name if story.section_name
    end
    integer :story_publication_id do
      story.publication_id if story.publication_name
    end
    integer :story_section_id do
      story.section_id if story.section_name
    end
    time :story_pubdate do
      story.pubdate if story
    end

  end

  def self.order_by_pubdate
    includes(:story).order('stories.pubdate desc')
  end


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
