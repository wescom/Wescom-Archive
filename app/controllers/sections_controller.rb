class SectionsController < ApplicationController
  def index
    @sections = Section.paginate(:page => params[:page], :per_page => 60, :order=> "name")
  end
end
