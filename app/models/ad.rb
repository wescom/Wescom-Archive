class Ad < ActiveRecord::Base

    has_attached_file :image, 
        :styles => { 
            :thumb => ["250x250>",:jpg],
            :large => ["500x500>",:jpg]
        },
        source_file_options:  { all: '-layers merge' },   #fixes transparency issue with PDFs
        :url => "/system/ad_images/:id/:style_:basename.:extension",  
        :path => ":rails_root/public/system/ad_images/:id/:style_:basename.:extension",
        :default_url => '/images/no-image.jpg'

    validates_attachment_content_type :image, :content_type => ["application/pdf"]

    searchable :auto_index => true, :auto_remove => true do
      # Search fields
      text :ad_id
      text :ad_name
      text :account
      text :customerName
      text :salesRepName

      # Sort fields - must use 'string' instead of 'text'
      string :ad_id
      string :ad_name
      string :account
      time :proof_date
      time :startDate
      time :stopDate

    end
end
