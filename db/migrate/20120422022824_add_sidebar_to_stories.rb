class AddSidebarToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :sidebar_head, :string
    add_column :stories, :sidebar_body, :string
  end

  def self.down
    remove_column :stories, :sidebar_body
    remove_column :stories, :sidebar_head
  end
end