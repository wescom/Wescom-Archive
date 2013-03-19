class AddLocationToPublication < ActiveRecord::Migration
  def self.up
    add_column :publications, :location_id, :integer
  end

  def self.down
    remove_column :publications, :location_id
  end
end
