class AddTownnewsFields < ActiveRecord::Migration[5.2]
    def self.up
        add_column :stories, :uuid, :binary, :limit => 16
        add_column :stories, :weblink, :string

        add_column :story_images, :uuid, :binary, :limit => 16
        add_column :story_images, :pubdate, :datetime
        add_column :story_images, :weblink, :string
    end

    def self.down
        remove_column :stories, :uuid
        remove_column :stories, :weblink
        
        remove_column :story_images, :uuid
        remove_column :story_images, :pubdate
        remove_column :story_images, :weblink
    end
end
