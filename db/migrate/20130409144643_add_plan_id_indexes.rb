class AddPlanIdIndexes < ActiveRecord::Migration[4.2]
  def up
    add_index :stories, :plan_id
    add_index :pdf_images, :plan_id
  end

  def down
    remove_index :stories, :plan_id
    remove_index :pdf_images, :plan_id
  end
end
