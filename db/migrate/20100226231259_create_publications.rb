class CreatePublications < ActiveRecord::Migration[4.2]
  def self.up
    create_table :publications do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :publications
  end
end
