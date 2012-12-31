class ChangeMediaOriginalcaptionToText < ActiveRecord::Migration
  def up
    change_table :story_images do |t|
      t.change :media_originalcaption, :text
    end
  end

  def down
    change_table :story_images do |t|
      t.change :media_originalcaption, :string
    end
  end
end
