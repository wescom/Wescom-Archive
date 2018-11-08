class AddCategoryToSections < ActiveRecord::Migration[4.2]
  def self.up
    add_column :sections, :category, :text
  end

  def self.down
    remove_column :sections, :category
  end
end
