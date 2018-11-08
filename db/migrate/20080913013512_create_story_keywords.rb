class CreateStoryKeywords < ActiveRecord::Migration[4.2]
  def self.up
    create_table :story_keywords do |t|
      t.integer :story_id, :keyword_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :story_keywords
  end
end
