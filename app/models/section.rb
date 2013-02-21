class Section < ActiveRecord::Base
  has_many :stories

  def category_plus_name
    if category?
      category+" - "+name
    else
      name
    end
  end
end
