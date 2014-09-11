class LatestController < ApplicationController
  
  # GET /shirts
  # GET /shirts.json
  def index
  	@sites = Site.all
  end
  
end
