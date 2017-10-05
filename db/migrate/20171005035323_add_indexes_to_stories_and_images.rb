class AddIndexesToStoriesAndImages < ActiveRecord::Migration
  def up
    add_index :stories, :categoryname
    add_index :stories, :subcategoryname
    add_index :stories, :web_pubnum

    add_index :story_images, :media_id
  end

  def down
    remove_index :stories, :categoryname
    remove_index :stories, :subcategoryname
    remove_index :stories, :web_pubnum

    remove_index :story_images, :media_id
  end

end
