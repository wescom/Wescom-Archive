class AddTextToPdfImage < ActiveRecord::Migration[4.2]
  def self.up
    add_column :pdf_images, :pdf_text, :text
  end

  def self.down
    remove_column :pdf_images, :pdf_text
  end
end
