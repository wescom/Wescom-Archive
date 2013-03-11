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
    add_index :pdf_images, :pubdate
    add_index :pdf_images, :publication
    add_index :pdf_images, :section_letter
    add_index :pdf_images, :page
  end

  def self.down
    drop_table :pdf_images
  end
end
