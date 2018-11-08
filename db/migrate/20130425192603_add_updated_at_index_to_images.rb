class AddUpdatedAtIndexToImages < ActiveRecord::Migration[4.2]
  def up
    add_index :story_images, :image_updated_at
  end

  def down
    remove_index :story_images, :image_updated_at
  end
end
