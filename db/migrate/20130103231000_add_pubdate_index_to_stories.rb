class AddPubdateIndexToStories < ActiveRecord::Migration[4.2]
  def self.up
    add_index :stories, :pubdate
  end

  def self.down
    remove_index :stories, :pubdate
  end
end
