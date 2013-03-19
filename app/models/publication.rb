class Publication < ActiveRecord::Base
  has_many :stories
  belongs_to :location
  belongs_to :publication_type
  
  validates_presence_of :name
end
