class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_user
    unless current_user
      redirect_to '/login?domain=amerine.net'
      return false
    end
  end

  helper_method :current_user, :signed_in?

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    !!current_user
  end
end
