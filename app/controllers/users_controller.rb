class UsersController < ApplicationController
  before_filter :require_user
  before_filter :require_admin

  def index
    @users = User.paginate(:page => params[:page], :order=> "updated_at DESC")
  end

  def show
    @user = User.find(params[:id])
    @logs = @user.logs.find(:all, :order => 'created_at DESC')
  end

  def edit
    @locations = Location.find(:all, :order => 'name')
    @pub_types = PublicationType.find(:all, :order => 'sort_order')

    @publications = Plan.where("pub_name is not null and pub_name<>''")
    @publications = @publications.where(:location_id => params[:location]) if params[:location].present?
    @publications = @publications.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @publications = @publications.select(:pub_name).uniq.order('pub_name')

    @sections = Plan.where("section_name is not null and section_name<>''")
    @sections = @sections.where(:location_id => params[:location]) if params[:location].present?
    @sections = @sections.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
    @sections = @sections.where(:pub_name => params[:pub_select]) if params[:pub_select].present?
    @sections = @sections.select(:section_name).uniq.order('section_name')

    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated"
      redirect_to users_url
    else
      render :action => :edit
    end
  end

end
