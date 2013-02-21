class SectionsController < ApplicationController
  def index
    @sections = Section.paginate(:page => params[:page], :order=> "name")
  end
end
