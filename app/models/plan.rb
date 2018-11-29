class Plan < ActiveRecord::Base
  has_many :stories
  has_many :pdf_images
  belongs_to :location, optional: true
  belongs_to :publication_type, optional: true
  has_many :logs, :dependent => :destroy

  def self.order_by_location_type_pub_section
    includes([:location, :publication_type]).order('locations.name').order('publication_types.name').order('pub_name').order('section_name').order('import_pub_name').order('import_section_letter')
  end
end
