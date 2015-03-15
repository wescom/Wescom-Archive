class PdfImage < ActiveRecord::Base
  belongs_to :plan

  has_attached_file :image, 
      :styles => { 
        :large => ["500x500>",:jpg]
      },
      :url => "/system/pdf_images/:id/:style_:basename.:extension",  
      :path => ":rails_root/public/system/pdf_images/:id/:style_:basename.:extension",
      :default_url => '/images/no-image.jpg'

  validates_presence_of :publication, :message=>'Publication Name is required'
  validates_presence_of :section_name, :message=>'Section Name is required'
  validates_presence_of :pubdate, :message=>'PubDate is required'
  validates_presence_of :image, :message=>'Image is required'

  def self.order_by_pubdate_section_page
    includes('plan').order('pubdate DESC').order('plans.pub_name').order('section_letter').order('plans.section_name').order('page')
  end
end
