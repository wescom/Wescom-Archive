class Location < ActiveRecord::Base
  has_many :plans
  has_many :publications
  
  validates_presence_of :name
  
  def self.order_by_location_type_pub_section
    includes([:plans]).order('name').order('plans.pub_name').order('plans.section_name').order('plans.import_pub_name').order('plans.import_section_name')
  end
  
end
