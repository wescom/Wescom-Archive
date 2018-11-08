class AddPageToStories < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :page, :string, :limit => 50
  end

  def self.down
    remove_column :stories, :page
  end
end
