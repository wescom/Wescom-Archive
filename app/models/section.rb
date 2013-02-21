class Section < ActiveRecord::Base
  has_many :stories
  has_many :section_categories

  def category_plus_name
    if category?
      category+" - "+name
    else
      name
    end
  end
end
