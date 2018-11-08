class AddPlanToStory < ActiveRecord::Migration[4.2]
  def self.up
    add_column :stories, :plan_id, :integer
  end

  def self.down
    remove_column :stories, :plan_id
  end
end
