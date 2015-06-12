namespace :wescom do
  desc "Import PDF text into pdf_text field"
  task :pdftext_import  => :environment do

    def import_pdftext()
      puts ""
      puts "Importing PDF text into database field pdf_text"
      pdf_images = PdfImage.find(:all)
      images_remaining = pdf_images.count
      #puts "*** PDF Images total: "+images_remaining.to_s

      pdf_images.each do |pdf|
        puts "*** PDF Images remaining: "+images_remaining.to_s+"......  Processing:  ID ##{pdf.id} - #{pdf.image_file_name}"

        # Read text within PDF file to use for fulltext indexing/searching
        yomu = Yomu.new pdf.image.path
        pdftext = yomu.text
        pdftext.gsub! /\n/, " "               # Clear newlines
        pdftext.gsub! "- ", ""                # Clear hyphens from justication
        pdf.pdf_text = pdftext
        pdf.save!
        
        images_remaining = images_remaining - 1
      end
      puts "Import complete"
      puts ""
    end
  
    import_pdftext

  end
end
