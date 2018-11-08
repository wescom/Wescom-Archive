class CreateCorrectionLinks < ActiveRecord::Migration[4.2]
  def self.up
    create_table :correction_links do |t|
      t.integer :story_id
      t.integer :correction_id

      t.timestamps
    end
  end

  def self.down
    drop_table :correction_links
  end
end
