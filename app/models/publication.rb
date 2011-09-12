class Publication < ActiveRecord::Base
  has_many :stories
end
