class AddFieldsToStory < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :pageset_letter, :string
    add_column :stories, :author, :string
    add_column :stories, :origin, :string
    add_column :stories, :deskname, :string
    add_column :stories, :categoryname, :string
    add_column :stories, :subcategoryname, :string
    add_column :stories, :memo, :text
    add_column :stories, :notes, :text
    add_column :stories, :expiredate, :datetime
    add_column :stories, :web_published_at, :datetime
  end

  def self.down
    remove_column :stories, :pageset_letter
    remove_column :stories, :author
    remove_column :stories, :origin
    remove_column :stories, :deskname
    remove_column :stories, :categoryname
    remove_column :stories, :subcategoryname
    remove_column :stories, :memo
    remove_column :stories, :notes
    remove_column :stories, :expiredate
    remove_column :stories, :web_published_at
  end
end
