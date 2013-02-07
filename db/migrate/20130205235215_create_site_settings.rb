class CreateSiteSettings < ActiveRecord::Migration
  def change
    create_table :site_settings do |t|
      t.text :site_announcement
      t.boolean :show_site_announcement
      
      t.timestamps
    end
  end
end
