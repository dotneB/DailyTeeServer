require 'net/http'
require 'open-uri'
require 'nokogiri'

class LatestController < ApplicationController
  
  #####
  DELAY_BETWEEN_UPDATE = 3.hour

  SITE_ID_DAILYTEESERVER = 1
  SITE_ID_SHIRTWOOT = 2
  SITE_ID_TEEFURY = 3
  SITE_ID_RIPTAPPAREL = 4
  #####

  # GET /shirts
  # GET /shirts.json
  def index
  	update()
  	@shirts = Shirt.where(:visible => true)
  end

  def update
  	dailyTeeServer = Site.find(SITE_ID_DAILYTEESERVER)
  	timeSinceLastUpdate = (Time.parse(DateTime.now.to_s) - Time.parse(dailyTeeServer.last_success.to_s))
  	if (timeSinceLastUpdate / DELAY_BETWEEN_UPDATE).round > 0
  		logger.info "[UPDATE - Start ===================================]"
  		logger.info sprintf("  It has been %d minutes since last update" , (timeSinceLastUpdate / 1.minute).round) 
  		
  		updateShirtWoot()
      updateTeeFury()
      updateRiptApparel()

  		dailyTeeServer.last_success = DateTime.now
  		dailyTeeServer.save()

  		logger.info "[UPDATE - Done ====================================]"
  	end
  end

  def find_or_create_Shirt(siteId, shirtName, shirtURL, shirtPhotoURL)
    logger.info shirtName
    logger.info shirtURL
    logger.info shirtPhotoURL

    thisShirt = Shirt.create_with(visible: true).find_or_create_by(:name => shirtName, :url => shirtURL, :image_url => shirtPhotoURL, :site_id => siteId)
    return thisShirt.id
  end

  def record_Success(siteId, todaysShirts)
    Shirt.where(:site_id => siteId, :visible => true).where.not(:id => todaysShirts).update_all(visible: false)

    thisSite = Site.find(siteId)
    thisSite.last_success = DateTime.now
    thisSite.save()
  end





  def updateShirtWoot
    logger.info "[=> Shirt Woot ====================================]"
  	
  	shirtwoot_api_url = sprintf("http://api.woot.com/2/events.json?site=shirt.woot.com&eventType=Daily&key=%s", ENV['SHIRTWOOT_API_KEY'])
    begin
      networkResponse = Net::HTTP.get_response(URI.parse(shirtwoot_api_url))
      jsonResult = JSON.parse(networkResponse.body)

      todaysShirts = Array.new
      jsonResult.first['Offers'].each do |offer|
        shirtName = offer['Title']
        shirtURL = offer['Url']
        shirtPhotoURL = offer['Photos'].last['Url']

        todaysShirts.push( find_or_create_Shirt(SITE_ID_SHIRTWOOT, shirtName, shirtURL, shirtPhotoURL) )
      end
      
      record_Success(SITE_ID_SHIRTWOOT, todaysShirts)
    rescue Exception => e
      logger.info "     Error parsing ShirtWoot API"
      logger.debug e.message
    end
  end





  def updateTeeFury
    logger.info "[=> TeeFury =======================================]"

    teefury_feed_url = "http://www.teefury.com/rss/rss.xml"
    begin
      teefury_feed = Nokogiri::XML(open(teefury_feed_url))
      teefury_feed.remove_namespaces!

      todaysShirts = Array.new
      teefury_feed.xpath("/feed/entry").each do |entry|
        shirtName = entry.xpath("title").first.content
        shirtURL = entry.xpath("link/@href").first.content
        shirtPhotoURL = entry.xpath("content/img/@src").first.content

        todaysShirts.push( find_or_create_Shirt(SITE_ID_TEEFURY, shirtName, shirtURL, shirtPhotoURL) )
      end
      
      record_Success(SITE_ID_TEEFURY, todaysShirts)
    rescue Exception => e
      logger.info "     Error parsing TeeFury feed"
      logger.debug e.message
    end
  end




  def updateRiptApparel
    logger.info "[=> Ript Apparel ==================================]"

    riptapparel_feed_url = "http://feeds.feedburner.com/riptapparel"
    begin
      riptapparel_feed = Nokogiri::XML(open(riptapparel_feed_url))
      riptapparel_feed.remove_namespaces!

      todaysShirts = Array.new
      riptapparel_feed.xpath("/rss/channel/item").take(3).each do |entry|
        shirtName = entry.xpath("title").first.content
        shirtURL = entry.xpath("link").first.content
        entry_description = Nokogiri::HTML( entry.xpath("description").first.content )
        entry_description.remove_namespaces!
        shirtPhotoURL = entry_description.css("img").first["src"]
        
        todaysShirts.push( find_or_create_Shirt(SITE_ID_RIPTAPPAREL, shirtName, shirtURL, shirtPhotoURL) )
      end
      
      record_Success(SITE_ID_RIPTAPPAREL, todaysShirts)
    rescue Exception => e
      logger.info "     Error parsing Ript Apparel feed"
      logger.debug e.message
    end
  end

end
