class CreatePlans < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.string :pub_name
      t.string :section_name
      t.string :import_pub_name
      t.string :import_section_name
      t.string :publication_type_id
      t.string :location_id
      t.timestamps
    end
  end

  def self.down
    drop_table :plans
  end
end
