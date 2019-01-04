namespace :wescom do
  desc "Import PDF pages"
  task :pdf_import  => :environment do
    # rake task accepts a date variable to force import of dates other than today. ie: bundle exec rake wescom:pdf_import date=16-07-2018
    
    def import_files
      files = get_daily_files
      files.each {|file| process_file(file)} unless files.nil?

      files = get_manual_files
      files.each {|file| process_file(file)} unless files.nil?
    end

    def get_daily_files
      # rake task accepts a date variable to force import of dates other than today. ie: bundle exec rake wescom:pdf_import date=16-07-2018
      if ENV['date'].nil?
        find_date = Date.today.strftime('%d-%m-%Y')
        puts "No date requested, defaulting to todays date: " + find_date
        puts "   - to request importing of specific date, add date=DD-MM-YYYY"
      else
        find_date = ENV['date']
        puts "Date requested: " +ENV['date']
      end
      #find_date = "03-01-2019"
      puts "\nSearching for PDF files published on "+find_date.to_date.strftime('%m-%d-%Y')
      pdf_files = File.join("/","WescomArchive","pdf-storage","archive-pdf",'**','*'+find_date+'{*.PDF,*.pdf}')
      puts "Path: "+pdf_files
      pdf_files = Dir.glob(pdf_files)
      pdf_files
    end

    def get_manual_files
      puts "\nSearching for PDF files in manual import folder"
      pdf_files = File.join("/","WescomArchive","pdf-storage","archive-pdf",'manual-import','**','{*.PDF,*.pdf}')
      puts "Path: "+pdf_files
      pdf_files = Dir.glob(pdf_files)
      pdf_files
    end

    def process_file(file)
      puts "Processing: #{file}"
      begin
        # filename example: C01_NEWS MAIN_28-05-2010_.PDF
        pdf_image = PdfImage.new(:image => File.open(file))
        filename = File.basename(file)
        path = File.path(file)
        pdf_image.pubdate = get_pubdate(filename)
        pdf_image.publication = get_publication(path)
        pdf_image.section_letter = get_section_letter(filename)
        pdf_image.section_name = get_section_name(filename)
        pdf_image.plan = Plan.find_or_create_by(pub_name: pdf_image.publication, import_section_name: pdf_image.section_name, import_section_letter: pdf_image.section_letter)
        pdf_image.page = get_page(filename)

        # Read text within PDF file to use for fulltext indexing/searching
        yomu = Yomu.new file
        pdftext = yomu.text
        pdftext.gsub! /\n/, " "                 # Clear newlines
        pdftext.gsub! "- ", ""                  # Clear hyphens from justication
        pdftext.gsub! /^[\w\-\s]+$/, ""        # Clear all non-alphanumeric characters
        pdf_image.pdf_text = pdftext
        
        #puts "Filename: "+filename
        #puts "PubDate: "+get_pubdate(filename).to_s
        #puts "Publication: "+get_publication(path).to_s
        #puts "Section Letter: "+get_section_letter(filename)
        #puts "Section Name: "+get_section_name(filename)
        #puts "Page: "+get_page(filename).to_s
        #puts "Pdf_text: "+pdftext
        pdf_image.save!
#        pdf_image.index!

        if file.include?('manual-import')
          newfile = '/WescomArchive/pdf-storage/archive-pdf/'+filename
          FileUtils.mv file, newfile
          puts "Moved to #{newfile}"
        end

        rescue Exception => e
          puts "Failed to Process File: #{file}\n Error: #{e}\n\n"
          FileUtils.mv file, '/data/archiveup/import_failed/'+filename
      end
    end
  
    def get_pubdate(filename)
      array_of_numbers = filename.split(/\D{1,2}/)
      year = array_of_numbers[-1]
      month = array_of_numbers[-2]
      day = array_of_numbers[-3]
      return pubdate = Date::strptime(array_of_numbers[-2]+"-"+array_of_numbers[-3]+"-"+array_of_numbers[-1], "%m-%d-%Y")
    end

    def get_publication(path)
      array_of_folders = path.split(/[\/]+/)
      pub_folder = array_of_folders[4]
      if pub_folder == "bend-bulletin"
        publication = "The Bulletin"
      else
        if pub_folder == "redmond-spokesman"
          publication = "Redmond Spokesman"
        else
          if pub_folder == "special-pubs"
            publication = "Special Pubs"
          else
            if pub_folder == "bend-conickel"
              publication = "The Nickel"
            else
              if pub_folder == "bend-comarket"
                publication = "CO Marketplace"
              else
                if pub_folder == "bend-misc"
                  publication = "The Bulletin"
                else
                  if pub_folder == "pulse"
                    publication = "Pulse"
                  else
                    if pub_folder == "manual-import"
                      publication = "The Bulletin"
                    end
                  end
                end
              end
            end
          end
        end
      end
      return publication
    end

    def get_section_letter(filename)
      array_of_letters = filename.split(/\d/)
      section_letter = array_of_letters[0]
      #puts "section_letter: "+section_letter
      return section_letter
    end

    def get_section_name(filename)
      array_of_letters = filename.split(/\d+/)
      array_of_letters[1].gsub! "_", ""
      section_name = array_of_letters[1]
      #puts "section_name: "+section_name
      return section_name
    end

    def get_page(filename)
      array_of_numbers = filename.split(/\D{1,3}/)
      if array_of_numbers[1].to_i == 0
        return array_of_numbers[0].to_i
      else
        return array_of_numbers[1].to_i
      end
    end
    
    import_files

  end
end
