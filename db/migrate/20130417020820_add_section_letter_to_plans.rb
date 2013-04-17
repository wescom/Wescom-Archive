class AddSectionLetterToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :import_section_letter, :string
  end

  def self.down
    remove_column :plans, :import_section_letter
  end
end
