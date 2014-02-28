class AddHtmltextToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :htmltext, :text
  end

  def self.down
    remove_column :stories, :htmltext
  end
end
