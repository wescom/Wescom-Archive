class CreatePdfImage < ActiveRecord::Migration
  def self.up
    create_table :pdf_images do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.date    :pubdate
      t.string  :publication
      t.string  :section_letter
      t.string  :section_name
      t.integer :page
    end
  end

  def self.down
    drop_table :pdf_images
  end
end
