namespace :wescom do
  desc "Import Ad PDFs"
  task :ad_import  => :environment do
    # rake task accepts a date variable to force import of dates other than today. ie: bundle exec rake wescom:pdf_import date=16-07-2018
    
    def import_files
      files = get_daily_files
      files.each {|file| process_file(file)} unless files.nil?
    end

    def get_daily_files
      # rake task accepts a date variable to force import of dates other than today. ie: bundle exec rake wescom:pdf_import date=16-07-2018
      if ENV['date'].nil?
        find_date = Date.today.strftime('%m-%d-%y')
        puts "No date folder requested, defaulting to todays date: " + find_date
        puts "   - to request importing of specific date folder, add date=MM-DD-YY"
      else
        find_date = ENV['date']
        puts "Date requested: " +ENV['date']
      end
      #find_date = "03-20-17"
      puts "\nSearching for Ad files within date folder "+find_date
      date_folder = find_date.gsub "-", ""
      pdf_files = File.join("/","WescomArchive","Ads_Backup",date_folder,'{*.PDF,*.pdf}')
      puts "Path: "+pdf_files
      pdf_files = Dir.glob(pdf_files)
      pdf_files
    end

    def process_file(file)
      puts "Processing: #{file}"
      begin
        # filename example: 20671751R.pdf
#ad = Ad.new(:image => File.open(file))
        filename = File.basename(file)
        path = File.path(file)
        ad_name = filename.gsub(".PDF",'').gsub(".pdf",'')

        ad_image = Ad.find_or_create_by(ad_name: ad_name)
        ad_image.image = File.open(file)
        #ad_image.ad_id = filename.gsub('/\D{1,2}/','')
        ad_image.ad_name = ad_name
        ad_image.proof_date = File.mtime(file)
        ad_image.frontend_db = "DTI"

        #puts "ad_id: "+ad_image.ad_id.to_s
        #puts "ad_name: "+ad_image.ad_name
        #puts "proof_date: "+ad_image.proof_date.to_s
        #puts "frontend_db: "+ad_image.frontend_db
        ad_image.save!
        ad_image.index!

    rescue Exception => e
          puts "Failed to Process File: #{file}\n Error: #{e}\n\n"
          FileUtils.cp file, '/WescomArchive/Ads_Backup/import_failed/'+filename
      end
    end
  
    import_files
  end
end
