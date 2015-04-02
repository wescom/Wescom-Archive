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
