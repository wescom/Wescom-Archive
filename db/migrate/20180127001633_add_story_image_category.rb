class AddStoryImageCategory < ActiveRecord::Migration[4.2]
  def self.up
    add_column :story_images, :media_category, :string

  end

  def self.down
    remove_column :story_images, :media_category
  end
end
