class DropColumnTopicFromStories < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :stories, :topic
  end

  def self.down
    add_column :stories, :topic
  end
end
