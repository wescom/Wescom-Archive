class AddPageToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :page, :string, :limit => 50
  end

  def self.down
    remove_column :stories, :page
  end
end
