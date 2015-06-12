namespace :wescom do
  desc "Import PDF text into pdf_text field"
  task :pdftext_import  => :environment do

    def import_pdftext()
      puts "Importing PDF text into database field pdf_text"
      pdf_images = PdfImage.find(:all)
      puts "*** PDF Images count: "+pdf_images.count.to_s

      pdf_images.each do |pdf|
        puts "Processing:  ID ##{pdf.id} - #{pdf.image_file_name}"

        # Read text within PDF file to use for fulltext indexing/searching
        yomu = Yomu.new pdf.image.path
        pdftext = yomu.text
        pdftext.gsub! /\n/, " "               # Clear newlines
        pdftext.gsub! "- ", ""                # Clear hyphens from justication
        pdf.pdf_text = pdftext
        pdf.save!
      end
    end
  
    import_pdftext

  end
end
