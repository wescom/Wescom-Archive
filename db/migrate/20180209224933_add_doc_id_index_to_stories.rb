class AddDocIdIndexToStories < ActiveRecord::Migration[4.2]
  def up
    add_index :stories, :doc_id
  end

  def down
    remove_index :stories, :doc_id
  end
end
