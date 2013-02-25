class AddShowDeleteToSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings, :show_delete_button, :boolean
  end

  def self.down
    remove_column :site_settings, :show_delete_button
  end
end
