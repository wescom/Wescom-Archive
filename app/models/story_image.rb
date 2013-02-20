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
      story.publication_name if story.present?
    end
    string :story_section_name do
      story.section_name if story.present?
    end
    integer :story_publication_id do
      story.publication_id if story.present?
    end
    integer :story_section_id do
      story.section_id if story.present?
    end
    integer :story_page do
      story.page if story.present?
    end
    time :story_pubdate do
      story.pubdate if story.present?
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

  def self.has_pubdate_in_range(date_from, date_to)
    date_from = Date.strptime(date_from, "%m/%d/%Y") if date_from.length > 0
    date_to = Date.strptime(date_to, "%m/%d/%Y") if date_to.length > 0
    if date_from.present? && date_to.present?
      includes(:story).where("stories.pubdate >= ?", date_from).where("stories.pubdate <= ?", date_to)
    else
      if date_from.present?
        includes(:story).where("stories.pubdate >= ?", date_from)
      else
        if date_to.present?
          includes(:story).where("stories.pubdate <= ?", date_to)
        else
          return scoped
        end
      end
    end
  end

  def self.has_section_id(id)
    return scoped unless id.present?
    includes(:story).where("stories.section_id = ?", id) if id
  end

  def self.has_publication_id(id)
    return scoped unless id.present?
    includes(:story).where("stories.publication_id = ?", id)
  end

end
