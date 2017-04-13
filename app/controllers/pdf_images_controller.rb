class PdfImagesController < ApplicationController
  before_filter :require_user

  def index
    @settings = SiteSettings.find(:first)
    @locations = Location.find(:all, :order => 'name')
    @pub_types = PublicationType.find(:all, :order => 'sort_order')
    @section_letters = PdfImage.select('section_letter').where("section_letter is not null and section_letter<>''").uniq

    scope = Plan.select(:pub_name).where("pub_name is not null and pub_name<>''")
    if !(params[:location].nil? or params[:location] == "")
      scope = scope.where(:location_id => params[:location])
    end
    if !(params[:pub_type].nil? or params[:pub_type] == "")
      scope = scope.where(:publication_type_id => params[:pub_type])
    end
    @publications = scope.uniq.order('pub_name')

    if params[:search_query]
      begin
        @pdf_images = PdfImage.search do
          paginate(:page => params[:page], :per_page => 16)
          fulltext params[:search_query]
          order_by :pubdate, :desc
          order_by :publication, :asc
          order_by :section_letter, :asc
          order_by :page, :asc
          with(:pubdate).greater_than_or_equal_to(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
          with(:pubdate).less_than_or_equal_to(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
          with :pdf_image_location_id, params[:location] if params[:location].present?
          with :pdf_image_pub_type_id, params[:pub_type] if params[:pub_type].present?
          with :publication, params[:pub_select] if params[:pub_select].present?
          with :section_letter, params[:sectionletter] if params[:sectionletter].present?
          with :page, params[:pagenum] if params[:pagenum].present?
      end
      rescue Errno::ECONNREFUSED
        render :text => "Search Server Down\n\n\n It will be back online shortly"
      end
    end
    increase_search_count
  end

  def book
    @locations = Location.find(:all, :order => 'name')
    @pub_types = PublicationType.find(:all, :order => 'sort_order')
    @section_letters = PdfImage.select('section_letter').where("section_letter is not null and section_letter<>''").uniq

    scope = Plan.select(:pub_name).where("pub_name is not null and pub_name<>''")
    if !(params[:location].nil? or params[:location] == "")
      scope = scope.where(:location_id => params[:location])
    end
    if !(params[:pub_type].nil? or params[:pub_type] == "")
      scope = scope.where(:publication_type_id => params[:pub_type])
    end
    @publications = scope.uniq.order('pub_name')

    scope = PdfImage
    if (params[:date_from_select].present?)
      scope = scope.where('DATE(pubdate) >= ?', Date.strptime(params[:date_from_select], "%m/%d/%Y"))
    end
    if (params[:date_to_select].present?)
      scope = scope.where('DATE(pubdate) <= ?', Date.strptime(params[:date_to_select], "%m/%d/%Y"))
    end
    if (params[:location].present?)
      scope = scope.includes('plan').where('plans.location_id = ?', params[:location])
    end
    if (params[:pub_type].present?)
      scope = scope.includes('plan').where('plans.publication_type_id = ?', params[:pub_type])
    end
    if (params[:pub_select].present?)
      scope = scope.includes('plan').where('plans.pub_name = ?', params[:pub_select])
    end
    if (params[:sectionletter].present?)
      scope = scope.where('section_letter = ?', params[:sectionletter])
    end
    if (params[:pagenum].present?)
      scope = scope.where('page = ?', params[:pagenum])
    end
    @pdf_images = scope.paginate(:page => params[:page], :per_page => 50).order_by_pubdate_sectionletter_page
    increase_search_count
  end

  def show
    @pdf_image = PdfImage.find(params[:id])
    @logs = @pdf_image.logs.find(:all, :order => 'created_at DESC')
    @last_updated = @logs.first
    render :layout => "plain"
  end

  def new
    @locations = Location.find(:all, :order => 'name')
    @pub_types = PublicationType.find(:all, :order => 'sort_order')
    @pdf_image = PdfImage.new
  end

  def create
    if params[:cancel_button]
      redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
          :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
          :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
    else
      section1_success = true
      section2_success = true
      section3_success = true

      ## Upload Section1 PDFs
      @pdf_images = params[:pdf_image][:image1]
      # Loop through each pdf file and save to database
      if @pdf_images.present?
        for i in (0..@pdf_images.length-1)
          # set pdf_image to current image in loop
          params[:pdf_image][:image] = @pdf_images[i]

          @pdf_image = PdfImage.new(params[:pdf_image])

          # Assign plan to this pdf_image
          @plan = Plan.find_or_create_by_location_id_and_publication_type_id_and_pub_name_and_section_name_and_import_section_letter(
                        params[:location],params[:pub_type],@pdf_image.publication,@pdf_image.section_name1,@pdf_image.section_letter1)
          @pdf_image.plan_id = @plan.id

          # Get page number from pdf filename
          @section_page = @pdf_image.image_file_name.match(/[a-zA-Z]\d{1,3}/).to_s
          @page = @section_page.match(/\d{1,3}/).to_s
          @pdf_image.page = @page

          @pdf_image.section_name = params[:pdf_image][:section_name1]
          @pdf_image.section_letter = params[:pdf_image][:section_letter1]
        
          if @pdf_image.save
            # Read text within PDF file to use for fulltext indexing/searching
            yomu = Yomu.new @pdf_image.image.path
            pdftext = yomu.text
            pdftext.gsub! /\n/, " "               # Clear newlines
            pdftext.gsub! "- ", ""                # Clear hyphens from justication
            @pdf_image.pdf_text = pdftext

            if @pdf_image.save
              Log.create_log("Pdf_image",@pdf_image.id,"Uploaded","PDF uploaded",current_user)
              flash[:notice] = "PDFs Uploaded"
              section1_success = true
            else
              Rails.logger.info "*** pdf_image failed save"
              flash[:error] = "PDF Upload Failed"
              section1_success = false
            end
          else
            Rails.logger.info "*** pdf_image failed save"
            flash[:error] = "PDF Upload Failed"
            section1_success = false
          end
        end
      else
        Rails.logger.info "*** pdf_images not present"
        flash[:error] = "PDF Upload Failed"
        section1_success = false
      end

      ## Upload Section2 PDFs
      @pdf_images = params[:pdf_image][:image2]
      # Loop through each pdf file and save to database
      if @pdf_images.present?
        for i in (0..@pdf_images.length-1)
          # set pdf_image to current image in loop
          params[:pdf_image][:image] = @pdf_images[i]

          @pdf_image = PdfImage.new(params[:pdf_image])

          # Assign plan to this pdf_image
          @plan = Plan.find_or_create_by_location_id_and_publication_type_id_and_pub_name_and_section_name_and_import_section_letter(
                        params[:location],params[:pub_type],@pdf_image.publication,@pdf_image.section_name2,@pdf_image.section_letter2)
          @pdf_image.plan_id = @plan.id

          # Get page number from pdf filename
          @section_page = @pdf_image.image_file_name.match(/[a-zA-Z]\d{1,3}/).to_s
          @page = @section_page.match(/\d{1,3}/).to_s
          @pdf_image.page = @page

          @pdf_image.section_name = params[:pdf_image][:section_name2]
          @pdf_image.section_letter = params[:pdf_image][:section_letter2]

          if @pdf_image.save
            # Read text within PDF file to use for fulltext indexing/searching
            yomu = Yomu.new @pdf_image.image.path
            pdftext = yomu.text
            pdftext.gsub! /\n/, " "               # Clear newlines
            pdftext.gsub! "- ", ""                # Clear hyphens from justication
            @pdf_image.pdf_text = pdftext

            if @pdf_image.save
              Log.create_log("Pdf_image",@pdf_image.id,"Uploaded","PDF uploaded",current_user)
              flash[:notice] = "PDFs Uploaded"
              section2_success = true
            else
              Rails.logger.info "*** pdf_image failed save"
              flash[:error] = "PDF Upload Failed"
              section2_success = false
            end
          else
            Rails.logger.info "*** pdf_image failed save"
            flash[:error] = "PDF Upload Failed"
            section2_success = false
          end
        end
      end

      ## Upload Section3 PDFs
      @pdf_images = params[:pdf_image][:image3]
      # Loop through each pdf file and save to database
      if @pdf_images.present?
        for i in (0..@pdf_images.length-1)
          # set pdf_image to current image in loop
          params[:pdf_image][:image] = @pdf_images[i]

          @pdf_image = PdfImage.new(params[:pdf_image])

          # Assign plan to this pdf_image
          @plan = Plan.find_or_create_by_location_id_and_publication_type_id_and_pub_name_and_section_name_and_import_section_letter(
                        params[:location],params[:pub_type],@pdf_image.publication,@pdf_image.section_name3,@pdf_image.section_letter3)
          @pdf_image.plan_id = @plan.id

          # Get page number from pdf filename
          @section_page = @pdf_image.image_file_name.match(/[a-zA-Z]\d{1,3}/).to_s
          @page = @section_page.match(/\d{1,3}/).to_s
          @pdf_image.page = @page

          @pdf_image.section_name = params[:pdf_image][:section_name3]
          @pdf_image.section_letter = params[:pdf_image][:section_letter3]

          if @pdf_image.save
            # Read text within PDF file to use for fulltext indexing/searching
            yomu = Yomu.new @pdf_image.image.path
            pdftext = yomu.text
            pdftext.gsub! /\n/, " "               # Clear newlines
            pdftext.gsub! "- ", ""                # Clear hyphens from justication
            @pdf_image.pdf_text = pdftext

            if @pdf_image.save
              Log.create_log("Pdf_image",@pdf_image.id,"Uploaded","PDF uploaded",current_user)
              flash[:notice] = "PDFs Uploaded"
              section3_success = true
            else
              Rails.logger.info "*** pdf_image failed save"
              flash[:error] = "PDF Upload Failed"
              section3_success = false
            end
          else
            Rails.logger.info "*** pdf_image failed save"
            flash[:error] = "PDF Upload Failed"
            section3_success = false
          end
        end
      end
      
      if section1_success and section2_success and section3_success
        redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
            :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
            :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
      else
        @locations = Location.find(:all, :order => 'name')
        @pub_types = PublicationType.find(:all, :order => 'sort_order')
        render :action => :new
#        redirect_to new_pdf_image_path(:pdf_image => params[:pdf_image])
      end
    end
  end
  
  def edit
    @locations = Location.find(:all, :order => 'name')
    @pub_types = PublicationType.find(:all, :order => 'sort_order')
    @section_letters = PdfImage.select('section_letter').where("section_letter is not null and section_letter<>''").uniq

    @pdf_image = PdfImage.find(params[:id])
    render :layout => "plain"
  end

  def update
    @pdf_image = PdfImage.find(params[:id])

    if params[:cancel_button]
      redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
          :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
          :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
    else
      @pdf_image.attributes=(params[:pdf_image])
      @plan = Plan.find_or_create_by_location_id_and_publication_type_id_and_pub_name_and_section_name_and_import_section_letter(
                    params[:location],params[:pub_type],@pdf_image.publication,@pdf_image.section_name,@pdf_image.section_letter)
      @pdf_image.plan_id = @plan.id
      if @pdf_image.save
        Log.create_log("Pdf_image",@pdf_image.id,"Updated","PDF edited",current_user)
        flash[:notice] = "PDF Updated"
        redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
            :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
            :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
      else
        flash[:error] = "PDF Update Failed"
        @locations = Location.find(:all, :order => 'name')
        @pub_types = PublicationType.find(:all, :order => 'sort_order')
        render :action => :edit, :layout => "plain"
      end
    end
  end
  
  def destroy
    @pdf_images = PdfImage.find(params[:id])
    if @pdf_images.destroy
      flash[:notice] = "PDF Killed!"
      redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
          :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
          :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
    else
      flash[:error] = "PDF Deletion Failed"
      redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
          :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
          :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
    end
  end
  
  private 
  
  def upload_section_pdfs(section_no)
    @pdf_images = params[:pdf_image][:image1]
    # Loop through each pdf file and save to database
    if @pdf_images.present?
      for i in (0..@pdf_images.length-1)
        # set pdf_image to current image in loop
        params[:pdf_image][:image] = @pdf_images[i]

        @pdf_image = PdfImage.new(params[:pdf_image])
puts "***** "+@pdf_image.inspect

        # Assign plan to this pdf_image
        @plan = Plan.find_or_create_by_location_id_and_publication_type_id_and_pub_name_and_section_name_and_import_section_letter(
                      params[:location],params[:pub_type],@pdf_image.publication,@pdf_image.section_name1,@pdf_image.section_letter1)
        @pdf_image.plan_id = @plan.id

        # Get page number from pdf filename
        @section_page = @pdf_image.image_file_name.match(/[a-zA-Z]\d{1,3}/).to_s
        @page = @section_page.match(/\d{1,3}/).to_s
        @pdf_image.page = @page

        @pdf_image.section_name = params[:pdf_image][:section_name1]
        @pdf_image.section_letter = params[:pdf_image][:section_letter1]
        
        if @pdf_image.save
          # Read text within PDF file to use for fulltext indexing/searching
          yomu = Yomu.new @pdf_image.image.path
          pdftext = yomu.text
          pdftext.gsub! /\n/, " "               # Clear newlines
          pdftext.gsub! "- ", ""                # Clear hyphens from justication
          @pdf_image.pdf_text = pdftext

          if @pdf_image.save
            Log.create_log("Pdf_image",@pdf_image.id,"Uploaded","PDF uploaded",current_user)
            flash[:notice] = "PDFs Uploaded"
            return true
          else
            Rails.logger.info "*** pdf_image failed save"
            flash[:error] = "PDF Upload Failed"
            return false
          end
        else
          Rails.logger.info "*** pdf_image failed save"
          flash[:error] = "PDF Upload Failed"
          return false
        end
      end
    else
      Rails.logger.info "*** pdf_images not present"
      flash[:error] = "PDF Upload Failed"
      return false
    end
  end
end
