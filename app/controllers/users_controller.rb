class UsersController < ApplicationController
  def index
    @users = User.paginate(:page => params[:page], :order=> "email")
  end

  def show
    @user = User.find(params[:id])
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
