class AddApprovedToStories < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :approved, :boolean
  end

  def self.down
    remove_column :stories, :approved
  end
end
