namespace :wescom do
  desc "Delete PDF pages"
  task :purge_duplicates  => :environment do

    def purge_dup_pdfs
      # Get a hash of all pdf image file names and how many records of each group
      counts = PdfImage.group([:image_file_name]).count
      #puts "counts: "+counts.to_yaml

      # Keep only those pairs that have more than one record, thus duplicates
      dupes = counts.select{|attrs, count| count > 1}
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

    def delete_pdf_by_year
      #find_date = Date.new('2009-01-01')
      find_year = 2012
      pdf_images = PdfImage.where('Year(pubdate) = ?', find_year).order_by_pubdate_section_page
      pdf_images.each  { |pdf|
        puts "ID:"+pdf.id.to_s + ", " + pdf.image_file_name+", = "+ pdf.count.to_s
      }
    end
    
    def purge_dup_stories
      # Get a hash of all pdf image file names and how many records of each group
      counts = Story.group([:doc_name]).count
      #puts "Story Duplicate count: "+counts.to_yaml

      # Keep only those pairs that have more than one record, thus duplicates
      dupes = counts.select{|attrs, count| count > 1}
      #puts "dupes: "+dupes.to_yaml

      # Map objects by the attributes we have.
      object_groups = dupes.map do |attrs, count|
        #puts "attrs: "+attrs
        Story.where(:doc_name => attrs)
      end

      # Take each group and destroy the duplicate, keeping only the first one.
      object_groups.each do |group|
        group.each_with_index do |object, index|
          puts "Duplicate Record=  "+"id:"+object.id.to_s + ", " + object.doc_name unless index == 0
          object.destroy unless index == 0
        end
      end
    end

    purge_dup_pdfs
    #delete_pdf_by_year
    purge_dup_stories

  end
end