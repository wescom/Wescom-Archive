class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  def require_user
    unless current_user
      redirect_to '/login?domain=wescompapers.com'
      return false
    end
  end
  
  def increase_search_count
    @user = current_user
    if @user.search_count.nil?
      @user.search_count = 0
    else
      @user.search_count += 1
    end
    @user.save
  end

  helper_method :current_user, :signed_in?

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    !!current_user
  end
  
  def require_admin
    unless admin?
      redirect_to '/search'
      return false
    end
  end

end
