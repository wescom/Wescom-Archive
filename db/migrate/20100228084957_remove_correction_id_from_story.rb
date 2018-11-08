class RemoveCorrectionIdFromStory < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :stories, :correction_id  
  end

  def self.down
    add_column :stories, :correction_id, :integer
  end
end
