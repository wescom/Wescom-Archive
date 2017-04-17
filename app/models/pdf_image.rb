class PdfImage < ActiveRecord::Base
  belongs_to :plan
  has_many :logs, :dependent => :destroy
  
  attr_accessor :section_name1, :section_letter1, :image1, :section_name2, :section_letter2, :image2, 
    :section_name3, :section_letter3, :image3, :section_name4, :section_letter4, :image4 

  has_attached_file :image, 
      :styles => { 
        :large => ["500x500>",:jpg]
      },
      :url => "/system/pdf_images/:id/:style_:basename.:extension",  
      :path => ":rails_root/public/system/pdf_images/:id/:style_:basename.:extension",
      :default_url => '/images/no-image.jpg'

  validates_presence_of :publication, :message=>'Publication Name is required'
  validates_presence_of :pubdate, :message=>'PubDate is required'
#  validates_presence_of :section_name, :message=>'Section Name is required'
#  validates_presence_of :image, :message=>'Image is required'
  validate :section1_upload, on: :create, :message=>'section1 missing data'
  validate :section2_upload, on: :create, :message=>'section2 missing data'
  validate :section3_upload, on: :create, :message=>'section3 missing data'
  validate :section4_upload, on: :create, :message=>'section4 missing data'

  searchable :auto_index => true, :auto_remove => true do
    # Search fields
    text :pdf_text

    # Sort fields - must use 'string' instead of 'text'
    integer :pdf_image_location_id do
      plan.location_id if plan.present?
    end
    integer :pdf_image_pub_type_id do
      plan.publication_type_id if plan.present?
    end
    time :pubdate
    string :publication
    string :section_letter
    integer :page
  end

  def self.order_by_pubdate_section_page
    includes('plan').order('pubdate DESC').order('plans.pub_name').order('section_letter').order('plans.section_name').order('page')
  end

  def self.order_by_pubdate_sectionletter_page
    includes('plan').order('pubdate DESC').order('plans.pub_name').order('section_letter').order('page')
  end
  
  def section1_upload
    if (section_name1.present? or section_letter1.present? or image1.present?) and (!section_name1.present? or !section_letter1.present? or !image1.present?)
      errors.add(:section_name1, "missing data")
    end
  end

  def section2_upload
    if (section_name2.present? or section_letter2.present? or image2.present?) and (!section_name2.present? or !section_letter2.present? or !image2.present?)
      errors.add(:section_name2, "missing data")
    end
  end

  def section3_upload
    if (section_name3.present? or section_letter3.present? or image3.present?) and (!section_name3.present? or !section_letter3.present? or !image3.present?)
      errors.add(:section_name3, "missing data")
    end
  end

  def section4_upload
    if (section_name4.present? or section_letter4.present? or image4.present?) and (!section_name4.present? or !section_letter4.present? or !image4.present?)
      errors.add(:section_name4, "missing data")
    end
  end

end
