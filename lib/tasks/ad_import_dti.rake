namespace :wescom do
  desc "Import Ad PDFs"
  task :ad_import  => :environment do
    # rake task accepts a date variable to force import of dates other than today. ie: bundle exec rake wescom:pdf_import date=16-07-2018
    
    def import_files
      # Get Newscycle Ad info to use when importing Ads
      require 'csv'
      csv_file = '/WescomArchive/archiveup/Newscycle_Ads.csv'
      ad_info = CSV.open(csv_file, headers: :first_row).map(&:to_h)
      #puts ad_info.inspect
      
      files = get_daily_files
      files.each {|file| process_file(file,ad_info)} unless files.nil?
    end

    def get_daily_files
      # rake task accepts a date variable to force import of dates other than current month. ie: bundle exec rake wescom:pdf_import date=16-07-2018
      if ENV['date'].nil?
        find_date = Date.today.strftime('%m-20-19')
        puts find_date
        puts "No date folder requested, defaulting to this month: " + find_date
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

    def process_file(file,ad_info)
      puts "Processing: #{file}"
      begin
        # filename example: 20671751R.pdf
        filename = File.basename(file)
        path = File.path(file)
        ad_name = filename.gsub(".PDF",'').gsub(".pdf",'').gsub("v2-",'').gsub("v3-",'')

        ad_image = Ad.find_or_create_by(ad_name: ad_name)
        ad_image.image = File.open(file)
        ad_image.ad_name = ad_name
        ad_image.proof_date = File.mtime(file)
        ad_image.frontend_db = "DTI"
        #puts "ad_id: "+ad_image.ad_id.to_s
        #puts "ad_name: "+ad_image.ad_name
        #puts "proof_date: "+ad_image.proof_date.to_s
        #puts "frontend_db: "+ad_image.frontend_db

        imported_ad_info = ad_info.select {|x| x["adName"] == ad_name}
        if !imported_ad_info.empty?
            ad_image.ad_id = imported_ad_info[0]["adId"]
            ad_image.startDate = imported_ad_info[0]["startDate"]
            ad_image.stopDate = imported_ad_info[0]["stopDate"]
            ad_image.issues = imported_ad_info[0]["issues"]
            ad_image.account = imported_ad_info[0]["account"]
            ad_image.customerName = imported_ad_info[0]["customerName"]
            ad_image.salesRepId = imported_ad_info[0]["salesRepId"]
            ad_image.salesRepName = imported_ad_info[0]["salesRepName"]
        end
        
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
