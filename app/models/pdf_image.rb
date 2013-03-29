class PdfImage < ActiveRecord::Base
  belongs_to :plan

  has_attached_file :image, 
      :styles => { 
        :large => ["500x500>",:jpg]
      },
      :url => "/system/pdf_images/:id/:style_:basename.:extension",  
      :path => ":rails_root/public/system/pdf_images/:id/:style_:basename.:extension",
      :default_url => '/images/no-image.jpg'

  def self.order_by_pubdate_section_page
    order('pubdate DESC').order('section_letter').order('page')
  end

end
