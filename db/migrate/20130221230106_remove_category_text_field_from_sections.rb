class RemoveCategoryTextFieldFromSections < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :sections, :category
  end

  def self.down
    add_column :sections, :category, :text
  end
end
