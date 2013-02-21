class AddCategoryToSection < ActiveRecord::Migration
  def self.up
    add_column :sections, :section_category_id, :integer
  end

  def self.down
    remove_column :sections, :section_category_id
  end
end
