class AddFieldsToStoryImages < ActiveRecord::Migration
  def self.up
    add_column :story_images, :media_webcaption, :text
    add_column :story_images, :byline_title, :string
    add_column :story_images, :deskname, :string
    add_column :story_images, :priority, :string
    add_column :story_images, :created_date, :datetime
    add_column :story_images, :last_refreshed_time, :datetime
    add_column :story_images, :expire_date, :datetime
  end

  def self.down
    remove_column :story_images, :expire_date
    remove_column :story_images, :last_refreshed_time
    remove_column :story_images, :created_date
    remove_column :story_images, :priority
    remove_column :story_images, :deskname
    remove_column :story_images, :byline_title
    remove_column :story_images, :media_webcaption
  end
end
