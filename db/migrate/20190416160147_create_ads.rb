class CreateAds < ActiveRecord::Migration[5.2]
  def self.up
      create_table :ads do |t|
        t.integer :ad_id
        t.string :ad_name
        t.string :image_file_name
        t.string :image_content_type
        t.integer :image_file_size
        t.datetime :image_updated_at

        t.datetime :proof_date
        t.string :frontend_db
        t.timestamp
      end
    end
    def self.down
      drop_table :ads
    end
end
