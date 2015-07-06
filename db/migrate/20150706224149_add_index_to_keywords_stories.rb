class AddIndexToKeywordsStories < ActiveRecord::Migration
  def up
    add_index :keywords_stories, [:story_id]
    add_index :keywords_stories, [:keyword_id]
  end

  def down
    remove_index :keywords_stories, [:story_id]
    remove_index :keywords_stories, [:keyword_id]
  end
end
