class Plan < ActiveRecord::Base
  has_many :stories
  belongs_to :location
  belongs_to :publication_type

  def self.order_by_location_type_pub_section
    includes([:location, :publication_type]).order('locations.name').order('publication_types.name').order('pub_name').order('section_name').order('import_pub_name').order('import_section_name')
  end
end
