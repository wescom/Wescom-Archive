class CreateStoryImages < ActiveRecord::Migration
  def self.up
    create_table :story_images do |t|
      t.integer :story_id
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.integer :media_id
      t.string :media_name
      t.integer :media_height
      t.integer :media_width
      t.string :media_mime_type
      t.string :media_source
      t.string :media_printcaption
      t.string :media_printproducer
      t.string :media_originalcaption
      t.string :media_source
      t.string :media_byline
      t.string :media_project_group
      t.string :media_notes
      t.string :media_status
      t.string :media_type
      t.string :publish_status
      t.timestamp
    end
  end

  def self.down
    drop_table :story_images
  end
end
