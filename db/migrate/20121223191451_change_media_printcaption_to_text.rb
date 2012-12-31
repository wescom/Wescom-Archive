class ChangeMediaPrintcaptionToText < ActiveRecord::Migration
  def up
    change_table :story_images do |t|
      t.change :media_printcaption, :text
    end
  end

  def down
    change_table :story_images do |t|
      t.change :media_printcaption, :string
    end
  end
end
