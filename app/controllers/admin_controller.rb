class AdminController < ApplicationController
  def index

  end
  def login
  	session[:password] = params[:password]
  	redirect_to shirts_path
  end
  def logout
  	reset_session
  	redirect_to admin_index_path
  end
end
