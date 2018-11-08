class AddPlanToPdfImages < ActiveRecord::Migration[4.2]
  def self.up
    add_column :pdf_images, :plan_id, :integer
  end

  def self.down
    remove_column :pdf_images, :plan_id
  end
end
