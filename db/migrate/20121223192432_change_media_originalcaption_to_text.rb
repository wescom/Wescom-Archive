class ChangeMediaOriginalcaptionToText < ActiveRecord::Migration[4.2]
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
