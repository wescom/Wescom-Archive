class PubnumToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :web_pubnum, :string

  end

  def self.down
    remove_column :stories, :web_pubnum
  end
end
