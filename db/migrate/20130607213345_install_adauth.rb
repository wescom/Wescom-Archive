class InstallAdauth < ActiveRecord::Migration
  def self.up
    add_column :users, :login, :string
    add_column :users, :name, :string
    add_column :users, :group_strings, :string
    add_column :users, :ou_strings, :string
    change_column :users, :role, :string, :default => "View"
    change_column :users, :search_count, :integer, :default => 0
  end

  def self.down
    remove_column :users, :login
    remove_column :users, :name
    remove_column :users, :group_strings
    remove_column :users, :ou_strings
  end
end
