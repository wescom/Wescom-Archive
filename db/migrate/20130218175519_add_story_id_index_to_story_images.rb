class AddStoryIdIndexToStoryImages < ActiveRecord::Migration
  def self.up
    add_index :story_images, :story_id
  end

  def self.down
    remove_index :story_images, :story_id
  end
end
