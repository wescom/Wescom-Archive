class AddSidebarToStories < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :sidebar_body, :text
  end

  def self.down
    remove_column :stories, :sidebar_body
  end
end
