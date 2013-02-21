class CreateSectionCategories < ActiveRecord::Migration
  def change
    create_table :section_categories do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :section_categories
  end
end
