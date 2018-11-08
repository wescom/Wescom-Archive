class AddCopyToStories < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :copy, :text
  end

  def self.down
    remove_column :stories, :copy
  end
end
