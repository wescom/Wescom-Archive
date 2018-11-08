class AddCategoryToSection < ActiveRecord::Migration[4.2]
  def self.up
    add_column :sections, :section_category_id, :integer
  end

  def self.down
    remove_column :sections, :section_category_id
  end
end
