class AddIndexesToPdfImages < ActiveRecord::Migration
  def up
    add_index :pdf_images, [:pubdate, :publication, :page], :name => 'date_pub_page'
    add_index :pdf_images, [:pubdate, :publication, :section_letter, :page], :name => 'date_pub_letter_page'
    add_index :pdf_images, [:pubdate, :publication, :section_letter, :section_name, :page], :name => 'date_pub_letter_name_page'
  end

  def down
    remove_index :pdf_images, [:pubdate, :publication, :page], :name => 'date_pub_page'
    remove_index :pdf_images, [:pubdate, :publication, :section_letter, :page], :name => 'date_pub_letter_page'
    remove_index :pdf_images, [:pubdate, :publication, :section_letter, :section_name, :page], :name => 'date_pub_letter_name_page'
  end
end
