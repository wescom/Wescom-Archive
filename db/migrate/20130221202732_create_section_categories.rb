class CreateSectionCategories < ActiveRecord::Migration[4.2]
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
