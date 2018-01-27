class AddStoryImageCategory < ActiveRecord::Migration
  def self.up
    add_column :story_images, :media_category, :string

  end

  def self.down
    remove_column :story_images, :media_category
  end
end
