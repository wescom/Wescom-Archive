class PdfImagesController < ApplicationController
  before_action :require_user

  def index
    @settings = SiteSettings.first
    @locations = Location.all.order('name')
    @pub_types = PublicationType.all.order('sort_order')
    @section_letters = PdfImage.select("DISTINCT section_letter").where("section_letter is not null and section_letter<>''").uniq

    scope = Plan.select("DISTINCT pub_name").where("pub_name is not null and pub_name<>''")
    if !(params[:location].nil? or params[:location] == "")
      scope = scope.where(:location_id => params[:location])
    end
    if !(params[:pub_type].nil? or params[:pub_type] == "")
      scope = scope.where(:publication_type_id => params[:pub_type])
    end
    @publications = scope.order('pub_name')

    if params[:search_query]
      begin
        @pdf_images = PdfImage.search do
          paginate(:page => params[:page], :per_page => 16)
          fulltext params[:search_query]
          with(:pubdate).greater_than_or_equal_to(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
          with(:pubdate).less_than_or_equal_to(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
          with :pdf_image_location_id, params[:location] if params[:location].present?
          with :pdf_image_pub_type_id, params[:pub_type] if params[:pub_type].present?
#          with :publication, params[:pub_select] if params[:pub_select].present?
          if params[:pub_select].present?
            with(:pdf_plan_publication, params[:pub_select])
          end
          with :section_letter, params[:sectionletter] if params[:sectionletter].present?
          with :page, params[:pagenum] if params[:pagenum].present?
          order_by :pubdate, :desc
          order_by :publication, :asc
          order_by :section_letter, :asc
          order_by :page, :asc
      end
      rescue Errno::ECONNREFUSED
        render :text => "Search Server Down\n\n\n It will be back online shortly"
      end
    end
    increase_search_count
    @total_pdfs_count = PdfImage.all.count
  end

  def book
    @locations = Location.all.order('name')
    @pub_types = PublicationType.all.order('sort_order')
    @section_letters = PdfImage.select("DISTINCT section_letter").where("section_letter is not null and section_letter<>''").uniq

    scope = Plan.select("DISTINCT pub_name").where("pub_name is not null and pub_name<>''")
    if !(params[:location].nil? or params[:location] == "")
      scope = scope.where(:location_id => params[:location])
    end
    if !(params[:pub_type].nil? or params[:pub_type] == "")
      scope = scope.where(:publication_type_id => params[:pub_type])
    end
    @publications = scope.order('pub_name')

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
    @logs = @pdf_image.logs.all.order('created_at DESC')
    @last_updated = @logs.first
    render :layout => "plain"
  end

  def new
    @locations = Location.all.order('name')
    @pub_types = PublicationType.all.order('sort_order')
    @pdf_image = PdfImage.new
  end

  def create
    if params[:cancel_button]
        redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
            :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
            :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
    else
        ## Upload Section PDFs
        @pdf_images = params[:pdf_image][:image]
        # Loop through each pdf file and save to database
        if @pdf_images.present?
            for i in (0..@pdf_images.length-1)
                # set pdf_image to current image in loop
                params[:pdf_image][:image] = @pdf_images[i]

                # Assign plan to this pdf_image
                @plan = Plan.find_or_create_by(
                            location_id: params[:location],
                            publication_type_id: params[:pub_type],
                            pub_name: params[:publication],
                            section_name: params[:pdf_image][:section_name],
                            import_section_letter: params[:pdf_image][:section_letter])
                params[:pdf_image][:plan_id] = @plan.id

                # Get page number from pdf filename
                @section_page = params[:pdf_image][:image].original_filename.match(/[a-zA-Z]\d{1,3}/).to_s
                @page = @section_page.match(/\d{1,3}/).to_s
                params[:pdf_image][:page] = @page

                @pdf_image = PdfImage.new(pdf_image_params)
                if @pdf_image.save
                    # Read text within PDF file to use for fulltext indexing/searching
                    yomu = Yomu.new @pdf_image.image.path
                    pdftext = yomu.text
                    pdftext.gsub! /\n/, " "               # Clear newlines
                    pdftext.gsub! "- ", ""                # Clear hyphens from justication
                    @pdf_image.pdf_text = pdftext

                    if @pdf_image.save
                        Log.create_log("Pdf_image",@pdf_image.id,"Uploaded","Section 1 PDFs uploaded",current_user)
                        flash_message :notice, "Section PDF Uploaded: "+@pdf_image.section_name.to_s+" "+@pdf_image.section_letter.to_s+@pdf_image.page.to_s
                        section_success = true
                    else
                        Rails.logger.info "*** pdf_image failed save"
                        flash_message :error, "PDF Upload Failed"
                        section_success = false
                    end
                else
                    Rails.logger.info "*** pdf_image failed save"
                    flash_message :error, "PDF Upload Failed"
                    section_success = false
                end
            end
        end
        if section_success
            redirect_to pdf_images_path(:date_from_select=>@pdf_image.pubdate.strftime('%m/%d/%Y').to_s, 
                :date_to_select=>@pdf_image.pubdate.strftime('%m/%d/%Y').to_s, 
                :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
                :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
        else
          @locations = Location.all.order('name')
          @pub_types = PublicationType.all.order('sort_order')
          render :action => :new
        end
    end
  end
  
  def edit
    @locations = Location.all.order('name')
    @pub_types = PublicationType.all.order('sort_order')
    @section_letters = PdfImage.select("DISTINCT section_letter").where("section_letter is not null and section_letter<>''").uniq

    @pdf_image = PdfImage.find(params[:id])
#    render :layout => "plain"
  end

  def update
    @pdf_image = PdfImage.find(params[:id])

    if params[:cancel_button]
      redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
          :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
          :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
    else
      if @pdf_image.update_attributes(pdf_image_params)
          @plan = Plan.find_or_create_by(
              location_id: params[:location],
              publication_type_id: params[:pub_type],
              pub_name: @pdf_image.publication,
              section_name: @pdf_image.section_name,
              import_section_letter: @pdf_image.section_letter)
          @pdf_image.plan_id = @plan.id
          if @pdf_image.save
            Log.create_log("Pdf_image",@pdf_image.id,"Updated","PDF edited",current_user)
            flash_message :notice, "PDF Updated"
            redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
                :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
                :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
          else
            flash_message :error, "PDF Update Failed"
            @locations = Location.all.order('name')
            @pub_types = PublicationType.all.order('sort_order')
            render :action => :edit, :layout => "plain"
          end
      else
        flash_message :error, "PDF Update Failed"
        @locations = Location.all.order('name')
        @pub_types = PublicationType.all.order('sort_order')
        render :action => :edit, :layout => "plain"
      end
    end
  end
  
  def destroy
    @pdf_images = PdfImage.find(params[:id])
    if @pdf_images.destroy
        flash_message :notice, "PDF Killed!"
        redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
            :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
            :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
    else
        flash_message :notice, "PDF Deletion Failed"
        redirect_to pdf_images_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select], 
            :location=>params[:location], :pub_type=>params[:pub_type], :pub_select=>params[:pub_select], 
            :sectionletter=>params[:sectionletter], :pagenum=>params[:pagenum])
    end
  end
  
  private
    def pdf_image_params
      params.require(:pdf_image).permit(:plan_id, :location, :pub_type, :publication, :pubdate, :section_name, :section_letter, :page, :image)
    end
    
    def validate_section1_upload
      if (params[:section_name1].present? or params[:section_letter1].present? or params[:image1].present?) and (params[:section_name1].empty? or params[:section_letter1].empty? or params[:image1].empty?)
        flash_message :error, "Section 1 missing data for upload"
        return false
      end
      return true
    end

    def validate_section2_upload
        if (params[:section_name2].present? or params[:section_letter2].present? or params[:image2].present?) and (params[:section_name2].empty? or params[:section_letter2].empty? or params[:image2].empty?)
          flash_message :error, "Section 2 missing data for upload"
          return false
        end
        return true
    end

    def validate_section3_upload
        if (params[:section_name3].present? or params[:section_letter3].present? or params[:image3].present?) and (params[:section_name3].empty? or params[:section_letter3].empty? or params[:image3].empty?)
          flash_message :error, "Section 3 missing data for upload"
          return false
        end
        return true
    end

    def validate_section4_upload
        if (params[:section_name4].present? or params[:section_letter4].present? or params[:image4].present?) and (params[:section_name4].empty? or params[:section_letter4].empty? or params[:image4].empty?)
          flash_message :error, "Section 4 missing data for upload"
          return false
        end
        return true
    end
end
