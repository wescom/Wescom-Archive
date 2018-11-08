class AddSearchCountToUsers < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :search_count, :integer
  end

  def self.down
    remove_column :users, :search_count
  end
end
