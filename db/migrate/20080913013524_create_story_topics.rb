class CreateStoryTopics < ActiveRecord::Migration[4.2]
  def self.up
    create_table :story_topics do |t|
      t.integer :story_id, :topic_id

      t.timestamps
    end
  end

  def self.down
    drop_table :story_topics
  end
end
