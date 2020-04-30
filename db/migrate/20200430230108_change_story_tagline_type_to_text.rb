class ChangeStoryTaglineTypeToText < ActiveRecord::Migration[5.2]
  def self.up
      change_column :stories, :tagline, :text
  end

  def self.down
      change_column :stories, :tagline, :string
  end
end
