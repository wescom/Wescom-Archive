class Location < ActiveRecord::Base
  has_many :plans
  has_many :publications
  
  validates_presence_of :name
  
end
