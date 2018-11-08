class AddFrontendDbToStory < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :frontend_db, :string
  end

  def self.down
    remove_column :stories, :frontend_db
  end
end
