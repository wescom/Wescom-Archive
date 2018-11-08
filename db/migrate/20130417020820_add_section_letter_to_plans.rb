class AddSectionLetterToPlans < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plans, :import_section_letter, :string
  end

  def self.down
    remove_column :plans, :import_section_letter
  end
end
