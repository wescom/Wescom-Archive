class AddExtraFieldsToAds < ActiveRecord::Migration[5.2]
    def self.up
        add_column :ads, :startDate, :datetime
        add_column :ads, :stopDate, :datetime
        add_column :ads, :issues, :integer
        add_column :ads, :account, :string
        add_column :ads, :customerName, :string
        add_column :ads, :salesRepId, :string
        add_column :ads, :salesRepName, :string
    end

    def self.down
        remove_column :ads, :startDate
        remove_column :ads, :stopDate
        remove_column :ads, :issues
        remove_column :ads, :account
        remove_column :ads, :customerName
        remove_column :ads, :salesRepId
        remove_column :ads, :salesRepName
    end
end
