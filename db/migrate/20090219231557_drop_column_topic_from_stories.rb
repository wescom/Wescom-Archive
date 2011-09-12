class DropColumnTopicFromStories < ActiveRecord::Migration
  def self.up
    remove_column :stories, :topic
  end

  def self.down
    add_column :stories, :topic
  end
end
