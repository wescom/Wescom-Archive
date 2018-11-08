class CreateLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :logs do |t|
      t.integer :user_id
      t.integer :story_id
      t.integer :story_image_id
      t.integer :plan_id
      t.integer :pdf_image_id
      
      t.string  :log_action
      t.string  :log_detail
      
      t.timestamps
    end
  end
end
