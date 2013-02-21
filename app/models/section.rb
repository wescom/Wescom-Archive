class Section < ActiveRecord::Base
  has_many :stories

  def category_plus_name
    category+" - "+name
  end
end
