class AddLocationToPublication < ActiveRecord::Migration[4.2]
  def self.up
    add_column :publications, :location_id, :integer
  end

  def self.down
    remove_column :publications, :location_id
  end
end
