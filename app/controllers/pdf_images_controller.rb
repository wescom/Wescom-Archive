class PdfImagesController < ApplicationController
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
    @pdf_images = scope.paginate(:page => params[:page], :per_page => 16).order_by_pubdate_section_page
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
    @pdf_images = scope.paginate(:page => params[:page], :per_page => 50).order_by_pubdate_section_page
    increase_search_count
  end

  def show
    @pdf_image = PdfImage.find(params[:id])
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
      @pdf_images = params[:pdf_image][:image]
      Rails.logger.info '***1****'+@pdf_images.to_s
      for i in (0..@pdf_images.length-1)
        Rails.logger.info '**2*****'+@pdf_images[i].to_s
        params[:pdf_image][:image] = @pdf_images[i]
        Rails.logger.info '**2*****'+params[:pdf_image][:image].to_s
  
        @pdf_image = PdfImage.new(params[:pdf_image])
        @plan = Plan.find_or_create_by_location_id_and_publication_type_id_and_pub_name_and_section_name_and_import_section_letter(
                      params[:location],params[:pub_type],@pdf_image.publication,@pdf_image.section_name,@pdf_image.section_letter)
        @pdf_image.plan_id = @plan.id

        if @pdf_image.save
          flash[:notice] = "PDF Created"
        else
          break
          flash[:error] = "PDF Creation Failed"
          @locations = Location.find(:all, :order => 'name')
          @pub_types = PublicationType.find(:all, :order => 'sort_order')
          render :action => :new
        end
      end
      flash[:notice] = "PDF Created"
      redirect_to pdf_images_path
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
  
end
