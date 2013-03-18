namespace :wescom do
  desc "Delete PDF pages"
  task :delete_pdf_pages  => :environment do

    def delete_duplicates
      # Get a hash of all pdf image file names and how many records of each group
      counts = PdfImage.group([:image_file_name]).count
      #puts "counts: "+counts.to_yaml

      # Keep only those pairs that have more than one record, thus duplicates
      dupes = counts.select{|attrs, count| count > 4}
      #puts "dupes: "+dupes.to_yaml

      # Map objects by the attributes we have.
      object_groups = dupes.map do |attrs, count|
        #puts "attrs: "+attrs
        PdfImage.where(:image_file_name => attrs)
      end

      # Take each group and destroy the duplicate pdf images, keeping only the first one.
      object_groups.each do |group|
        group.each_with_index do |object, index|
          puts "Duplicate Record=  "+"id:"+object.id.to_s + ", " + object.image_file_name unless index == 0
          object.destroy unless index == 0
        end
      end
    end

    def delete_by_year
      #find_date = Date.new('2009-01-01')
      find_year = 2012
      pdf_images = PdfImage.where('Year(pubdate) = ?', find_year).order_by_pubdate_section_page
      pdf_images.each  { |pdf|
        puts "ID:"+pdf.id.to_s + ", " + pdf.image_file_name+", = "+ pdf.count.to_s
      }
    end
    

    delete_duplicates
    #delete_by_year

  end
end