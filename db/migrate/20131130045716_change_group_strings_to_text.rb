class ChangeGroupStringsToText < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.change :group_strings, :text
    end
  end

  def down
    change_table :users do |t|
      t.change :group_strings, :string
    end
  end
end
