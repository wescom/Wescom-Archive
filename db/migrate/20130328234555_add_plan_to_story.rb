class AddPlanToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :plan_id, :integer
  end

  def self.down
    remove_column :stories, :plan_id
  end
end
