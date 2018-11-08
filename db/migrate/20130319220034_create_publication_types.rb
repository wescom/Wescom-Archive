class CreatePublicationTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :publication_types do |t|
      t.string  :name
      t.integer :sort_order
      t.timestamps
    end
  end

  def self.down
    drop_table :publication_types
  end
end
