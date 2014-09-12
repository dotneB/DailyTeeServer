require 'net/http'

class LatestController < ApplicationController
  
  # GET /shirts
  # GET /shirts.json
  def index
  	updateShirtWoot()
  	@sites = Site.all
  end

  def needUpdate

  end

  def updateShirtWoot
  	logger.info Site.minimum("last_success")

  	shirtwoot_api_url = "http://api.woot.com/2/events.json?site=shirt.woot.com&eventType=Daily&key=02cede2337cb416f9526935712dcc7f9"
    resp = Net::HTTP.get_response(URI.parse(shirtwoot_api_url))
    data = resp.body
    result = JSON.parse(data)

    item = result.first
    
    item['Offers'].each do |offer|
      logger.info offer['Title']
      logger.info offer['Photos'].last['Url']
    end
  end
end
