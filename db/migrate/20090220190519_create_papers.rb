class CreatePapers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :papers do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :papers
  end
end
