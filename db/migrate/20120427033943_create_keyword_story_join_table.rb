class CreateKeywordStoryJoinTable < ActiveRecord::Migration
  def self.up
    drop_table :story_keywords
    create_table :keywords_stories, :id => false do |t|
      t.integer :story_id
      t.integer :keyword_id
    end
  end

  def self.down
    drop_table :keywords_stories
    create_table :story_keywords do |t|
      t.integer :story_id, :keyword_id
    end
  end

end
