class AddCopyToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :copy, :text
  end

  def self.down
    remove_column :stories, :copy
  end
end
