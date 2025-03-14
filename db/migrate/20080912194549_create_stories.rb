class CreateStories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :stories do |t|
      t.string :headline, :topic
      t.date :pubdate

      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end
