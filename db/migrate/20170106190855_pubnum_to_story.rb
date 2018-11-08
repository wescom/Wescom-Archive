class PubnumToStory < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :web_pubnum, :string

  end

  def self.down
    remove_column :stories, :web_pubnum
  end
end
