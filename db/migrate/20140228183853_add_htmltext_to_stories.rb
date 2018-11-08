class AddHtmltextToStories < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :htmltext, :text
  end

  def self.down
    remove_column :stories, :htmltext
  end
end
