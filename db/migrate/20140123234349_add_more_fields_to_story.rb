class AddMoreFieldsToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :related_stories, :string
    add_column :stories, :web_hl1, :string
    add_column :stories, :web_hl2, :string
    add_column :stories, :web_text, :text
    add_column :stories, :toolbox2, :text
    add_column :stories, :toolbox3, :text
    add_column :stories, :toolbox4, :text
    add_column :stories, :toolbox5, :text
    add_column :stories, :web_summary, :text
    add_column :stories, :kicker, :string
    add_column :stories, :videourl, :string
    add_column :stories, :alternateurl, :string
    add_column :stories, :map, :string
    add_column :stories, :caption, :text
  end

  def self.down
    remove_column :stories, :related_stories
    remove_column :stories, :web_hl1
    remove_column :stories, :web_hl2
    remove_column :stories, :web_text
    remove_column :stories, :toolbox2
    remove_column :stories, :toolbox3
    remove_column :stories, :toolbox4
    remove_column :stories, :toolbox5
    remove_column :stories, :web_summary
    remove_column :stories, :kicker
    remove_column :stories, :videourl
    remove_column :stories, :alternateurl
    remove_column :stories, :map
    remove_column :stories, :caption
  end
end
