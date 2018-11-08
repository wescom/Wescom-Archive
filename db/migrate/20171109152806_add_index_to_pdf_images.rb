class AddIndexToPdfImages < ActiveRecord::Migration[4.2]
  def up
    add_index :pdf_images, [:section_letter, :page], :name => 'letter_page'
    add_index :pdf_images, [:pubdate, :section_letter, :page], :name => 'date_letter_page'
  end

  def down
    remove_index :pdf_images, [:section_letter, :page], :name => 'letter_page'
    remove_index :pdf_images, [:pubdate, :section_letter, :page], :name => 'date_letter_page'
  end
end
