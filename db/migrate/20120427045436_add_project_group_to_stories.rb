class AddProjectGroupToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :project_group, :string
  end

  def self.down
    remove_column :stories, :project_group
  end
end
