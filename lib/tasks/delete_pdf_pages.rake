namespace :wescom do
  desc "Delete PDF pages"

  task :delete_pdf_pages  => :environment do
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

  task :delete_pdf_by_year  => :environment do
      #find_date = Date.new('2009-01-01')
      find_year = 2012
      pdf_images = PdfImage.where('Year(pubdate) = ?', find_year).order_by_pubdate_section_page
      pdf_images.each  { |pdf|
        puts "ID:"+pdf.id.to_s + ", " + pdf.image_file_name+", = "+ pdf.count.to_s
      }
  end

  task :delete_pdf_by_date  => :environment do
    if ENV['date'].nil?
        puts "No date requested!"
        puts "   - to request deleting specific date, add date=YYYY-MM-DD"
    else
        find_date = ENV['date']
        puts "Purge Date: " +ENV['date']
        #find_date = "03-01-2019"

        pdf_images = PdfImage.where('pubdate = ?', find_date).order_by_pubdate_section_page
        pdf_images.each  { |pdf|
            puts "Purging PDF => ID:"+pdf.id.to_s + ", " + pdf.image_file_name
            pdf.destroy
        }
    end
  end
end