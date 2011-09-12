class AddBylineToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :byline, :string
  end

  def self.down
    remove_column :stories, :byline
  end
end
