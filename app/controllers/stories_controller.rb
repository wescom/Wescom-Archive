class StoriesController < ApplicationController
  before_action :require_user
  before_action :last_page
 
  def show
    @story = Story.where(:id => params[:id]).includes(:corrections, :corrected_stories).first
    @logs = @story.logs.all.order('created_at DESC')
    @last_updated = @logs.first
    
    if @story.plan.present?
      scope = PdfImage.includes('plan').where(:pubdate=>@story.pubdate).where('plans.pub_name = ?',@story.plan.pub_name)
      if (@story.pageset_letter.present?)
        scope = scope.where('section_letter = ?', @story.pageset_letter)
      end
      if (@story.page.present?) and (@story.pageset_letter.present?)
        scope = scope.where('page = ?', @story.page)
      end
      @pdf_image = scope.order_by_pubdate_section_page.first
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml do  
        stream = render_to_string(:template=>"stories/show" )  
        send_data(stream, :type=>"text/xml",:filename => @story.doc_name+'.xml')
      end
    end
  end
  
  def new
  end
  
  def create
  end
  
  def edit
    @story = Story.find(params[:id])
    @papers = Paper.all.order("name")
    @sections = Section.order_by_category_plus_name.all
  end

  def update
    @story = Story.find(params[:id])
    @papers = Paper.all.order("name")
    @sections = Section.order_by_category_plus_name.all

    if params[:cancel_button]
      redirect_to story_path
    else
      if @story.update_attributes(story_params)
        Log.create_log("Story",@story.id,"Updated","Story edited",current_user)
        flash_message :notice, "Story Updated"
        redirect_to story_path
      else
        flash_message :notice, "Story Update Failed"
        render :action => :edit
      end
    end
  end
  
  def approve
    @story = Story.find(params[:story_id])
    @story.approved = true
    if @story.save
      Log.create_log("Story",@story.id,"Approved","Story approved",current_user)
      flash[:notice] = "Story Approved"
      redirect_to story_path(@story)
    else
      flash[:error] = "Story Approval Failed"
      redirect_to story_path(@story)
    end
  end
  
  def import_to_DTI
    @story = Story.find(params[:story_id])

    if !@story.pubdate.nil?
      # Create xml file from story data
      file_contents = render_to_string :file => 'stories/show.xml.builder'
      if !@story.doc_name.nil?
        xml_filename = ('/WescomArchive/archiveup/exported_to_cloud_dti/archive_'+@story.doc_name+'.xml').gsub(" ","_").gsub("-","_")
      else
        xml_filename = ('/WescomArchive/archiveup/exported_to_cloud_dti/archive_TheBulletin_'+@story.pubdate.to_s+'.xml').gsub(" ","_").gsub("-","_")
      end
      File.open(xml_filename,'w'){|f| f.write file_contents}
      #render :text => file_contents  #dont render the xml file to screen, render the story instead after ftp

      # write IPTC data to attached images
      Rails.logger.info "\nExporting images out of database"
      image_path = '/WescomArchive/archiveup/exported_to_cloud_dti/archive_'
      require 'mini_exiftool'
      xml_file_images = []
    	@story.story_images.each do |image|
        if !image.image_file_name.nil?
      	  Rails.logger.info "Exporting... "+image_path+image.image_file_name
      	  FileUtils.cp(image.image.path(:original), image_path+image.image_file_name)
      	  Rails.logger.info "Writing IPTC data to image... "
          pic = MiniExiftool.new image_path+image.image_file_name
          if !@story.doc_name.nil?
            pic.specialinstructions = "j=archive_"+@story.doc_name.gsub(" ","_").gsub("-","_")  # job = story name. DTI will attach image to the story upon import.
          end
          xml_file_images.push(image_path+image.image_file_name)  # create array of image files for this story
          pic.save
          #Rails.logger.info "************************* "+pic.specialinstructions
        end
			end

      # FTP Credentials
      host = 'tbb-ftp.tbb.us1.dti'
      user = 'batchsync'
      passwd = 'Password1'

      # FTP xml file to DTI's story import folder and attached images to autoload news media folder
      require 'double_bag_ftps'
      ftps = DoubleBagFTPS.new
      ftps.ssl_context = DoubleBagFTPS.create_ssl_context(:verify_mode => OpenSSL::SSL::VERIFY_NONE, :ssl_version  => "SSLv3")
      #ftps.debug_mode = true
      ftps.passive = true
      ftps.connect(host)
      ftps.login(user, passwd)
      puts "\n*** FTP Connection to " + host + " ***"
      ftps.welcome
      # FTP xml file to import folder
      ftps.chdir("/Interfaces/Story Import/FileIn")
      ftps.putbinaryfile(xml_filename)
      puts "Remote directory list of /Interfaces/Story Import/FileIn/ after transfer"
      puts ftps.list  # Output file listing of remote folder
      # FTP images to import folder
      ftps.chdir("/Refresh News Media/")
      xml_file_images.each do |image|
      ftps.putbinaryfile(image)
      end
      puts "Remote directory list of /Autoload News Media/ after transfer"
      puts ftps.list  # Output file listing of remote folder
      ftps.close

      Rails.logger.info "\n*** FTP transfer to DTI story import folder complete: " + xml_filename
      flash[:notice] = "Story exported to Cloud DTI"
    else
      Rails.logger.info "\n*** FTP transfer to DTI story failed - NO PUBDATE"
      flash[:error] = "Story export failed - NO PUBDATE"
    end
    
    redirect_to story_path(@story)

  end
  
  def destroy
    @story = Story.find(params[:id])
    if @story.destroy
      flash[:notice] = "Story Killed!"
      redirect_to :back and return unless request.referrer == story_path(@story)
      redirect_to search_path
    else
      flash[:error] = "Story Deletion Failed"
      redirect_to :back and return unless request.referrer == story_path(@story)
      redirect_to search_path
    end
  end

  private
  def last_page
    session[:last_page] = request.env['HTTP_REFERER']
  end

  def story_params
    params.require(:story).permit(:approved, :kicker, :hl1, :hl2, :byline, :paper_id, :copy, :tagline, :sidebar, :toolbox2, :toolbox3, :toolbox4, :toolbox5,
      :web_hl1, :web_hl2, :web_text, :htmltext, :web_summary, :videourl, :alternateurl, :map, :pubdate, :section_id, :page, :project_group,
      :categoryname, :subcategoryname)
  end
end
