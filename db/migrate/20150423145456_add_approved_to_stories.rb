class AddApprovedToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :approved, :boolean
  end

  def self.down
    remove_column :stories, :approved
  end
end
