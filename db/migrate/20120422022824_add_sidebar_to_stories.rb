class AddSidebarToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :sidebar_body, :text
  end

  def self.down
    remove_column :stories, :sidebar_body
  end
end