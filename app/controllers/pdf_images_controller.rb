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

  def destroy
    @pdf_images = PdfImage.find(params[:id])
    if @pdf_images.destroy
      flash[:notice] = "PDF Killed!"
      redirect_to pdf_images_path
    else
      flash[:error] = "PDF Deletion Failed"
      redirect_to pdf_images_path
    end
  end
  
end
