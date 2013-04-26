class AddIndexesToPlanTable < ActiveRecord::Migration
  def up
    add_index :plans, :location_id
    add_index :plans, :publication_type_id
    add_index :plans, :pub_name
    add_index :plans, :section_name
  end

  def down
    remove_index :plans, :location_id
    remove_index :plans, :publication_type_id
    remove_index :plans, :pub_name
    remove_index :plans, :section_name
  end
end
