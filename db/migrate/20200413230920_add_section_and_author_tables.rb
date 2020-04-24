class AddSectionAndAuthorTables < ActiveRecord::Migration[5.2]
    def self.up
        # sections used for stories and images.
        # sections table already exists for plans. will use current table for plans, stories and images.
        #create_table :sections do |t|
        #    t.string :name
        #    t.timestamps
        #end
        # links for stories and images
        create_table :sections_stories, :id => false do |t|
            t.integer :story_id
            t.integer :section_id
        end
        add_index :sections_stories, [:story_id]
        add_index :sections_stories, [:section_id]

        create_table :sections_story_images, :id => false do |t|
            t.integer :story_image_id
            t.integer :section_id
        end
        add_index :sections_story_images, [:story_image_id]
        add_index :sections_story_images, [:section_id]


        # flags used for stories and images.
        create_table :flags do |t|
            t.string :name
            t.timestamps
        end
        # links for stories and images
        create_table :flags_stories, :id => false do |t|
            t.integer :story_id
            t.integer :flag_id
        end
        add_index :flags_stories, [:story_id]
        add_index :flags_stories, [:flag_id]

        create_table :flags_story_images, :id => false do |t|
            t.integer :story_image_id
            t.integer :flag_id
        end
        add_index :flags_story_images, [:story_image_id]
        add_index :flags_story_images, [:flag_id]


        # authors used for stories and images.
        create_table :authors do |t|
            t.string :name
            t.timestamps
        end
        # links for stories and images
        create_table :authors_stories, :id => false do |t|
            t.integer :story_id
            t.integer :author_id
        end
        add_index :authors_stories, [:story_id]
        add_index :authors_stories, [:author_id]

        create_table :authors_story_images, :id => false do |t|
            t.integer :story_image_id
            t.integer :author_id
        end
        add_index :authors_story_images, [:story_image_id]
        add_index :authors_story_images, [:author_id]

        # keywords used for images. (stories already set up for keywords in previous migrations)
        create_table :keywords_story_images, :id => false do |t|
            t.integer :story_image_id
            t.integer :keyword_id
        end
        add_index :keywords_story_images, [:story_image_id]
        add_index :keywords_story_images, [:keyword_id]
    end

    def self.down
        drop_table :keywords_story_images
        drop_table :authors_story_images
        drop_table :authors_stories
        drop_table :authors
        drop_table :flags_story_images
        drop_table :flags_stories
        drop_table :flags
        drop_table :sections_story_images
        drop_table :sections_stories
#        drop_table :sections

    end
end
