class AddProjectGroupToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :project_group, :string
    add_index :stories, :project_group
  end

  def self.down
    remove_index :stories, :project_group
    remove_column :stories, :project_group
  end
end