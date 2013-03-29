namespace :wescom do
  desc "Import PDF pages"
  task :pdf_import  => :environment do

    def import_files
      files = get_files
      files.each {|file| process_file(file)}
    end

    def get_files
      find_date = Date.today.strftime('%d-%m-%Y')
      puts "Searching for PDF files published on "+find_date.to_date.strftime('%m-%d-%Y')
      #find_date = "01-03-2013"
      pdf_files = File.join("/","WescomArchive","pdf-storage","archive-pdf",'**','*'+find_date+'{*.PDF,*.pdf}')
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
        pdf_image.plan = Plan.find_or_create_by_import_pub_name_and_import_section_name(pdf_image.publication,pdf_image.section_name)
        pdf_image.page = get_page(filename)

        #puts "Filename: "+filename
        #puts "PubDate: "+get_pubdate(filename).to_s
        #puts "Publication: "+get_publication(path).to_s
        #puts "Section Letter: "+get_section_letter(filename)
        #puts "Section Name: "+get_section_name(filename)
        #puts "Page: "+get_page(filename).to_s
        pdf_image.save!
  #        pdf_image.index!

        rescue Exception => e
          puts "Failed to Process File: #{file}\n Error: #{e}\n\n"
          FileUtils.cp file, '/data/archiveup/import_failed/'+filename
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
