class AddFrontendDbToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :frontend_db, :string
  end

  def self.down
    remove_column :stories, :frontend_db
  end
end
