class AddDefaultsToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :default_location_id, :integer
    add_column :users, :default_publication_type_id, :integer
    add_column :users, :default_publication, :string
    add_column :users, :default_section_name, :string
  end

  def self.down
    remove_column :users, :default_location_id
    remove_column :users, :default_publication_type_id
    remove_column :users, :default_publication
    remove_column :users, :default_section_name
  end
end
