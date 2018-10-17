class UsersController < ApplicationController
  before_action :require_user
  before_action :require_admin, only: [:index, :destroy]

  def index
    @users = User.paginate(:page => params[:page]).order("updated_at DESC")
  end

  def show
    @user = User.find(params[:id])
    # Only allow users to view/edit their own profile
    if current_user == @user or admin?
      @logs = @user.logs.all.order('created_at DESC')
    else
      redirect_to user_path(current_user.id)
    end
  end

  def edit
    @user = User.find(params[:id])
    # Only allow users to view/edit their own profile
    if current_user == @user or admin?
      @locations = Location.all.order('name')
      @pub_types = PublicationType.all.order('sort_order')

      @publications = Plan.where("pub_name is not null and pub_name<>''")
      @publications = @publications.where(:location_id => params[:location]) if params[:location].present?
      @publications = @publications.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
      @publications = @publications.select("DISTINCT pub_name").order('pub_name')

      @sections = Plan.where("section_name is not null and section_name<>''")
      @sections = @sections.where(:location_id => params[:location]) if params[:location].present?
      @sections = @sections.where(:publication_type_id => params[:pub_type]) if params[:pub_type].present?
      @sections = @sections.where(:pub_name => params[:pub_select]) if params[:pub_select].present?
      @sections = @sections.select("DISTINCT section_name").order('section_name')
    else
      redirect_to user_path(current_user.id)
    end
  end

  def update
    @user = User.find(params[:id])
    # Only allow users to view/edit their own profile
    if current_user == @user or admin?
      if @user.update_attributes(params[:user])
        flash[:notice] = "Account updated"
        redirect_to users_url
      else
        render :action => :edit
      end
    else
      redirect_to user_path(current_user.id)
    end
  end

end
