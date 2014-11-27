require 'net/http'
require 'open-uri'
require 'nokogiri'

require 'ShirtWootSite'
require 'TeeFurySite'
require 'RiptApparelSite'
require 'TheYeTeeSite'
require 'QwerteeSite'
require 'OtherTeesSite'

class LatestController < ApplicationController
  
  #####
  SITE_ID_DAILYTEESERVER = 1
  #####

  # GET /shirts
  # GET /shirts.json
  def index
    begin
      update()
    rescue Exception => e
      logError e.message
    end
    if request.format == Mime::JSON
      headers['Access-Control-Allow-Origin'] = '*' 
      headers['Access-Control-Request-Method'] = '*'
    end
    @shirts = Shirt.where(:visible => true).order('created_at DESC')
    
    begin
      Shirt.where("created_at < :keep_shirts_for AND site_id <> 1", {:keep_shirts_for => 3.day.ago}).delete_all
    rescue Exception => e
      logError e.message
    end
  end

  def update
    dailyTeeServer = Site.find(SITE_ID_DAILYTEESERVER)
    if dailyTeeServer.last_success.to_i < 3.hour.ago.to_i
      logInfo "[UPDATE - Start ===================================]"
      start_time = Time.now
      timeSinceLastUpdate = (Time.parse(DateTime.now.to_s) - Time.parse(dailyTeeServer.last_success.to_s))
      logInfo sprintf("  It has been %d minutes since last update" , (timeSinceLastUpdate / 1.minute).round) 
      
      updateOtherTees()
      updateQwertee()
      updateTheYeTee()
      updateRiptApparel()
      updateTeeFury()
      updateShirtWoot()

      dailyTeeServer.last_success = DateTime.now
      dailyTeeServer.save()

      logInfo "[UPDATE - Done ====================================]"
      end_time = Time.now
      logInfo "  Update took #{(end_time - start_time)*1000} milliseconds"
    end
  end

  def logInfo(message)
    logger.info "[DTS][INFO] " + message
  end

  def logError(message)
    logger.info "[DTS][ERROR] " + message
  end

  def find_or_create_Shirt(siteId, shirtName, shirtURL, shirtPhotoURL)
    logInfo shirtName
    logInfo shirtURL
    logInfo shirtPhotoURL

    thisShirt = Shirt.create_with(visible: true, :name => shirtName, :url => shirtURL, :image_url => shirtPhotoURL).find_or_create_by(:original_hash => Digest::SHA1.base64digest(shirtName + shirtURL + shirtPhotoURL), :site_id => siteId)
    return thisShirt.id
  end

  def record_Success(siteId, todaysShirts)
    Shirt.where(:site_id => siteId, :visible => true).where.not(:id => todaysShirts).update_all(visible: false)

    thisSite = Site.find(siteId)
    thisSite.last_success = DateTime.now
    thisSite.save()
  end





  def updateShirtWoot
    logInfo "[=> Shirt Woot ====================================]"
    begin
      todaysShirts = Array.new
      shirts = ShirtWootSite::downloadFeedAndExtractShirts() 
      shirts.each do |shirt|
        todaysShirts.push( find_or_create_Shirt(shirt[:siteId], shirt[:shirtName], shirt[:shirtURL], shirt[:shirtPhotoURL]) )
      end
      record_Success(ShirtWootSite::SITE_ID, todaysShirts)
    rescue Exception => e
      logError "Error parsing ShirtWoot API"
      logError e.message
    end
  end





  def updateTeeFury
    logInfo "[=> TeeFury =======================================]"
    begin
      todaysShirts = Array.new
      shirts = TeeFurySite::downloadFeedAndExtractShirts() 
      shirts.each do |shirt|
        todaysShirts.push( find_or_create_Shirt(shirt[:siteId], shirt[:shirtName], shirt[:shirtURL], shirt[:shirtPhotoURL]) )
      end
      record_Success(TeeFurySite::SITE_ID, todaysShirts)
    rescue Exception => e
      logError "Error parsing TeeFury feed"
      logError e.message
    end
  end




  def updateRiptApparel
    logInfo "[=> Ript Apparel ==================================]"
    begin
      todaysShirts = Array.new
      shirts = RiptApparelSite::downloadFeedAndExtractShirts() 
      shirts.each do |shirt|
        todaysShirts.push( find_or_create_Shirt(shirt[:siteId], shirt[:shirtName], shirt[:shirtURL], shirt[:shirtPhotoURL]) )
      end
      record_Success(RiptApparelSite::SITE_ID, todaysShirts)
    rescue Exception => e
      logError "Error parsing Ript Apparel feed"
      logError e.message
    end
  end




  def updateTheYeTee
    logInfo "[=> TheYeTee ======================================]"
    begin
      todaysShirts = Array.new
      shirts = TheYeTeeSite::downloadFeedAndExtractShirts() 
      shirts.each do |shirt|
        todaysShirts.push( find_or_create_Shirt(shirt[:siteId], shirt[:shirtName], shirt[:shirtURL], shirt[:shirtPhotoURL]) )
      end
      record_Success(TheYeTeeSite::SITE_ID, todaysShirts)
    rescue Exception => e
      logError "Error parsing TheYeTee feed"
      logError e.message
    end
  end




  def updateQwertee
    logInfo "[=> Qwertee =======================================]"
    begin
      todaysShirts = Array.new
      shirts = QwerteeSite::downloadFeedAndExtractShirts() 
      shirts.each do |shirt|
        todaysShirts.push( find_or_create_Shirt(shirt[:siteId], shirt[:shirtName], shirt[:shirtURL], shirt[:shirtPhotoURL]) )
      end
      record_Success(QwerteeSite::SITE_ID, todaysShirts)
    rescue Exception => e
      logError "Error parsing Qwertee feed"
      logError e.message
    end
  end




  def updateDesignByHumans
    # Design By Humans no longer has a daily tee
    return
    logInfo "[=> Design By Humans ==============================]"
    logInfo "Not Implemented"
  end




  def updateOtherTees
    logInfo "[=> Other Tees ====================================]"
    begin
      todaysShirts = Array.new
      shirts = OtherTeesSite::downloadFeedAndExtractShirts() 
      shirts.each do |shirt|
        todaysShirts.push( find_or_create_Shirt(shirt[:siteId], shirt[:shirtName], shirt[:shirtURL], shirt[:shirtPhotoURL]) )
      end
      record_Success(OtherTeesSite::SITE_ID, todaysShirts)
    rescue Exception => e
      logError "Error parsing OtherTees feed"
      logError e.message
    end
  end

end
