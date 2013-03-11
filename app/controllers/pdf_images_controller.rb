class PdfImagesController < ApplicationController
  def index
    @settings = SiteSettings.find(:first)
    @publications = Publication.find(:all)

    scope = PdfImage
    if (params[:date_from_select].present?)
      scope = scope.where('DATE(pubdate) >= ?', Date.strptime(params[:date_from_select], "%m/%d/%Y"))
    end
    if (params[:date_to_select].present?)
      scope = scope.where('DATE(pubdate) <= ?', Date.strptime(params[:date_to_select], "%m/%d/%Y"))
    end
    if (params[:pagenum].present?)
      scope = scope.where('page = ?', params[:pagenum])
    end
    @pdf_images = scope.paginate(:page => params[:page], :per_page => 16).order_by_pubdate_section_page
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
