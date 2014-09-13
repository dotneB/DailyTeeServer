class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :isAdmin?

  def isAdmin?
    Digest::SHA1.base64digest( session[:password] ) == ENV['DTS_ADMIN_SECRET']
  end

  def authorize
    unless isAdmin?
      flash[:error] = "unauthorized access"
      redirect_to admin_index_path
      false
    end
  end

end
