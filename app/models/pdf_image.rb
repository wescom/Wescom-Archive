class PdfImage < ActiveRecord::Base
  belongs_to :plan, optional: true
  has_many :logs, :dependent => :destroy
  
  has_attached_file :image, 
      :styles => { 
        :large => ["500x500>",:jpg]
      },
      source_file_options:  { all: '-layers merge' },
      :url => "/system/pdf_images/:id/:style_:basename.:extension",  
      :path => ":rails_root/public/system/pdf_images/:id/:style_:basename.:extension",
      :default_url => '/images/no-image.jpg'

  validates_presence_of :publication, :message=>'Publication Name is required'
  validates_presence_of :pubdate, :message=>'PubDate is required'
#  validates_presence_of :section_name, :message=>'Section Name is required'
#  validates_presence_of :image, :message=>'Image is required'
#  validates :section1_upload, on: :create, presence: { message: 'section1 missing data' }
#  validates :section2_upload, on: :create, presence: { message: 'section2 missing data' }
#  validates :section3_upload, on: :create, presence: { message: 'section3 missing data' }
#  validates :section4_upload, on: :create, presence: { message: 'section4 missing data' }

#  validates_attachment_content_type :image, :content_type => ["application/pdf"]
  do_not_validate_attachment_file_type :image   # Explicitly do not validate

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
    string :pdf_plan_publication do
      plan.pub_name if plan.present?
    end
    string :pdf_plan_section_name do
      plan.section_name if plan.present?
    end
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
