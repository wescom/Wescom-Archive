namespace :wescom do
  desc "Export PDF pages"

  task :export_pdfs_by_site  => :environment do
    if ENV['site'].nil?
        puts "No site requested!   - to request specific site, add site='#' "
        
        locations = Location.all.order('id')
        locations.each { |x|
            puts x.id.to_s + " - " + x.name
        }
    else
        site = ENV['site']
        location = Location.where('location_no = ?', site).first
        puts "Exporting: " + location.name

        pdf_images = PdfImage.includes(:plan).where(:plans => { location_id: location }).order(:publication).order(:pubdate)
        pdf_images.each  { |pdf|
            #puts pdf.plan.location.name
            #puts pdf.plan.pub_name
            #puts pdf.pubdate.to_s
            #puts pdf.image_file_name

            publication_date = pdf.pubdate.nil? ? 'NoPubDate' : pdf.pubdate.to_s
            publication_name = pdf.plan.pub_name.nil? ? 'NoPubName' : pdf.plan.pub_name
            puts publication_date
            puts publication_name
            dirname = '/WescomArchive/archiveup/exports/'+pdf.plan.location.name+'/'+publication_name+'/'+publication_date+'/'
            puts dirname
            FileUtils.mkdir_p(dirname) unless File.exists?(dirname)
            FileUtils.cp "./public/system/pdf_images/"+pdf.id.to_s+"/original_"+pdf.image_file_name, dirname+pdf.image_file_name
            puts "    "+dirname+pdf.image_file_name

        }
    end
  end
  
end