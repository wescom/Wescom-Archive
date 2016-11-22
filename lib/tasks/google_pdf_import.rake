namespace :wescom do
  desc "Import PDF text into pdf_text field"
  task :import_google_pdf, [:number_of_records_to_import] => :environment do |t, args|

    def import_google_pdf(records_to_import)

      require 'csv'
    
      puts ""
      puts "Importing Google PDFs into database"

    #-----------------------------------
      # Read info.csv file into array
      # Loop through RollId rows in array
        # read Pub, Pubdate and Page Range into variables
        # Download RollId from Google if needed
          # Read ContentMetaData file (verify correct data within folder for pub and pubdates)
        # Convert PNG files to PDF
        # Rename PDF files to 01_The Bulletin_DD-MM-YYYY_.PDF
        # Get OCR text from Google file
        # Move PDF files into import folder
        # Mark date completed        
    #-----------------------------------

        #------#
        # MAIN #
        #------#
    
        # Directory to store downloaded Google PDF files
        #directory_of_Google_PDFs = "/Volumes/wescomarchive/Google_PDF_Archives/"
        directory_of_Google_PDFs = "/WescomArchive/Google_PDF_Archives/"
        #directory_for_pdf_imports = "/Volumes/pdf-storage/archive-pdf/manual-GooglePDF-import/"
        directory_for_pdf_imports = "/WescomArchive/pdf-storage/archive-pdf/manual-GooglePDF-import/" 
        
        # define an array to hold the info.csv records
        arr = Array.new

        # open the csv file
        csv_file = directory_of_Google_PDFs + "Bulletin_info.csv"
        f = CSV.read(csv_file)

        old_folder = ""

        # Count imported records in array f so we can skip them
        imported_records = 0
        f.each do |line|
          if line[5] == "imported"
            imported_records = imported_records + 1
            #puts line.inspect
          end 
        end

        # loop through each non-imported records in the csv file
        f[imported_records..imported_records+records_to_import-1].each do |line|
          # line[0] = Folder Name
          # line[1] = Start_page - End_page
          # line[2] = Publication
          # line[3] = PubDate YYYYMMDD
          # line[4] = Record #
          # line[5] = 'imported' or blank

          puts ""
          puts "*** File record: " + line.inspect
          # check if line has already been imported
          if line[5] != "imported"
            # Download the PDF directory
            directory_name = directory_of_Google_PDFs + line[0]
            puts ' Creating directory... ' + directory_name
            system(" mkdir " + directory_name + " >nul 2>&1")
            system('gsutil -m rsync -r gs://10053342_western_communications_inc/' + line[0] + ' ' + directory_name)

            # read ContentMetadata file and verify pub and pubdate
        
            #Convert PNG files to PDF and rename to syntax 01_The Bulletin_DD-MM-YYYY_.PDF
            pages = line[1].split("-")
            start_page = pages[0].to_i
            end_page = pages[1].to_i
            current_page = 0
            while start_page <= end_page  do
              root_image_filename = directory_name + "/CLEAN_IMAGE/" + start_page.to_s
              root_ocr_filename = directory_name + "/OCR_HTML/" + start_page.to_s
          
              pub = line[2]
              current_page = current_page + 1
              page = current_page.to_s.rjust(2, "0")
              pub_year = line[3].to_s[0..3]
              pub_month = line[3].to_s[4..5]
              pub_day = line[3].to_s[6..7]
              puts(" " + pub + " - " + pub_day + "/" + pub_month + "/" + pub_year + " page " + page)

              # Convert PNG image into PDF
              puts("   converting page... "+ root_image_filename + ".png" )
              if File.exist?(root_image_filename + ".png")
                system("convert " + root_image_filename + ".png " + root_image_filename + ".pdf")

                # Rename PDF file to PAGENO_PUBNAME_DD-MM-YYYY_.PDF
                puts("   renaming page... "+ root_image_filename + ".png")
                new_PDF_filename = page + "_" + line[2] + "_" + pub_day + "-" + pub_month + "-" + pub_year + "_.PDF"
                new_PDF_filename = new_PDF_filename.gsub(" ","\\ ")   # Account for any spaces in pub name
                system("mv " + root_image_filename + ".pdf " + directory_name + "/CLEAN_IMAGE/" + new_PDF_filename)
          
                # Get OCR text from Google file and write to new file PAGENO_GOOGLE_DD-MM-YYYY_.txt
                puts("   grabbing OCR text... "+ root_ocr_filename + ".html")
                if File.exist?(root_ocr_filename + ".html")
                  file = File.open(root_ocr_filename + ".html", "rb")
                  ocr_text = file.read
                  ocr_text = ocr_text.gsub("<style>span {position:absolute}</style>", '')
                  ocr_text = ocr_text.gsub(/<\/?[^>]*>/, '').gsub(/\n\n+/, "\n").gsub(/^\n|\n$/, '').gsub(/\n/, ' ')
                  new_OCR_filename = directory_name + "/OCR_HTML/" + page + "_" + line[2] + "_" + pub_day + "-" + pub_month + "-" + pub_year + "_.txt"
                  File.open(new_OCR_filename, "w:#{ocr_text.encoding.name}") { |file| file.write(ocr_text) }
                else
                  puts "   - OCR file does not exist: " + root_ocr_filename + ".html"
                end
              else
                puts "   - Image file does not exist: " + root_image_filename + ".png"
              end

              start_page +=1
            end
        
            # Move PDF and OCR files to import folder
            puts(" Moving PDF files to Wescom Archive import folder... " + directory_for_pdf_imports)
            system("cp " + directory_name + "/CLEAN_IMAGE/*.PDF" + " " + directory_for_pdf_imports)
            system("rm " + directory_name + "/CLEAN_IMAGE/*.PDF")
            puts(" Moving OCR files to Wescom Archive import folder... " + directory_for_pdf_imports)
            system("cp " + directory_name + "/OCR_HTML/*.txt" + " " + directory_for_pdf_imports)
            system("rm " + directory_name + "/OCR_HTML/*.txt")

            # mark csv line as imported
            line << "imported"
            # write out latest version of csv file with current line marked imported
            new_csv_file = directory_of_Google_PDFs + "Bulletin_info.csv"
            CSV.open(new_csv_file, 'w') do |csv_object|
              f.each do |row_array|
                csv_object << row_array
              end
            end

            # Remove downloaded Google folder from local system if no longer needed
            if line[0] != old_folder and old_folder != ""
              puts(" Removing old downloaded Google folder... " + directory_of_Google_PDFs + old_folder)
              system("rm -r " + directory_of_Google_PDFs + old_folder)
            end
            old_folder = line[0]

            puts(" File Record Converted: " + line.inspect)

            # Get array of PDFs to import into database
            #pdf_files = File.join("/","Volumes","pdf-storage","archive-pdf",'manual-GooglePDF-import','**','{*.PDF,*.pdf}')
            pdf_files = File.join("/","WescomArchive","pdf-storage","archive-pdf",'manual-GooglePDF-import','**','{*.PDF,*.pdf}')
            pdf_files = Dir.glob(pdf_files)

            # Import list of PDF into database
            puts " Files to import into Wescom Archive: " + pdf_files.count.to_s
            pdf_files.each {|file| process_file(file,directory_for_pdf_imports)} unless pdf_files.nil?

            puts(" *** PDFs Imported: " + line.inspect)
            puts("")
          end
        end

      puts "Import complete"
      puts ""
      
      rescue Exception => e
        puts "Failed to get File: #{file}\n Error: #{e}\n\n"
    end

    def process_file(file,directory_for_pdf_imports)
      puts "  Importing: #{file}"
      begin
        # filename example: 01_The Bulletin_28-05-2010_.PDF
        pdf_image = PdfImage.new(:image => File.open(file))
        filename = File.basename(file)
        path = File.path(file)
        pdf_image.pubdate = get_pubdate(filename)
        pdf_image.publication = get_publication(filename)
        pdf_image.section_letter = get_section_letter(filename)
        pdf_image.section_name = "Main"
        pdf_image.plan = Plan.find_or_create_by_import_pub_name_and_import_section_name_and_import_section_letter(pdf_image.publication,pdf_image.section_name,pdf_image.section_letter)
        pdf_image.page = get_page(filename)

        # Get text from OCR file to use for fulltext indexing/searching
        ocr_file = filename.gsub(".PDF",".txt")
        if File.exist?(directory_for_pdf_imports + ocr_file)
          pdftext = File.read(directory_for_pdf_imports + ocr_file)
          pdf_image.pdf_text = pdftext
        else
          pdf_image.pdf_text = ""
        end

        #puts "Filename: "+filename
        #puts "PubDate: "+get_pubdate(filename).to_s
        #puts "Publication: "+get_publication(path).to_s
        #puts "Section Letter: "+get_section_letter(filename)
        #puts "Section Name: "+pdf_image.section_name
        #puts "Page: "+get_page(filename).to_s
        #puts "Pdf_text: "+pdftext
        pdf_image.save!
#        pdf_image.index!

        #Move PDF for archive and remove OCR file
        system("mv " + file.gsub(" ","\\ ") + " " + '/WescomArchive/pdf-storage/archive-pdf/' + filename.gsub(" ","\\ "))
        if File.exist?(directory_for_pdf_imports + ocr_file.gsub(" ","\\ "))
          system("rm " + directory_for_pdf_imports + ocr_file.gsub(" ","\\ "))
        end

        rescue Exception => e
          puts "Failed to Import File into archive: #{file}\n Error: #{e}\n\n"
          #FileUtils.cp file, '/data/archiveup/import_failed/'+filename
      end
    end

    def get_pubdate(filename)
      array_of_numbers = filename.split(/\D{1,2}/)
      year = array_of_numbers[-1]
      month = array_of_numbers[-2]
      day = array_of_numbers[-3]
      return pubdate = Date::strptime(array_of_numbers[-2]+"-"+array_of_numbers[-3]+"-"+array_of_numbers[-1], "%m-%d-%Y")
    end

    def get_publication(filename)
      array_of_letters = filename.split(/\d+/)
      array_of_letters[1].gsub! "_", ""
      publication = array_of_letters[1]
      return publication
    end

    def get_section_letter(filename)
      array_of_letters = filename.split(/\d/)
      section_letter = array_of_letters[0]
      #puts "section_letter: "+section_letter
      return section_letter
    end

    def get_page(filename)
      array_of_numbers = filename.split(/\D{1,3}/)
      if array_of_numbers[1].to_i == 0
        return array_of_numbers[0].to_i
      else
        return array_of_numbers[1].to_i
      end
    end
    
    #
    
    # set number of records to import from CSV file based on paramter passed to task. If none, import 1 record.
    if args[:number_of_records_to_import]
      records_to_import = args[:number_of_records_to_import]
    else
      records_to_import = "1"
    end
    puts "number: " + records_to_import.to_s

    import_google_pdf(records_to_import)

  end
end
