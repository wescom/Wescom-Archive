class Publication < ActiveRecord::Base
  has_many :stories
  belongs_to :location
  
  validates_presence_of :name
end
