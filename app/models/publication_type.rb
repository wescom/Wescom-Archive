class PublicationType < ActiveRecord::Base
  has_many :publications
  
  validates_presence_of :name
end
