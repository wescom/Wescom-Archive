class AddTypeToPublication < ActiveRecord::Migration[4.2]
  def self.up
    add_column :publications, :publication_type_id, :integer
  end

  def self.down
    remove_column :publications, :publication_type_id
  end
end
