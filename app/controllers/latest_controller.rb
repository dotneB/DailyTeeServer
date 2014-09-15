require 'net/http'
require 'open-uri'
require 'nokogiri'

class LatestController < ApplicationController
  
  #####
  DELAY_BETWEEN_UPDATE = 3.hour
  KEEP_SHIRTS_FOR = 3.day.ago

  SITE_ID_DAILYTEESERVER = 1
  SITE_ID_SHIRTWOOT = 2
  SITE_ID_TEEFURY = 3
  SITE_ID_RIPTAPPAREL = 4
  SITE_ID_THEYETEE = 5
  SITE_ID_QWERTEE = 6
  SITE_ID_DESIGNBYHUMANS = 7
  SITE_ID_OTHERTEES = 8
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
    @shirts = Shirt.where(:visible => true).order('site_id, id DESC')
    
    begin
      Shirt.where("created_at < :keep_shirts_for AND site_id <> 1", {:keep_shirts_for => KEEP_SHIRTS_FOR}).delete_all
    rescue Exception => e
      logError e.message
    end
  end

  def update
    dailyTeeServer = Site.find(SITE_ID_DAILYTEESERVER)
    timeSinceLastUpdate = (Time.parse(DateTime.now.to_s) - Time.parse(dailyTeeServer.last_success.to_s))
    if (timeSinceLastUpdate / DELAY_BETWEEN_UPDATE).round > 0
      logInfo "[UPDATE - Start ===================================]"
      start_time = Time.now
      logInfo sprintf("  It has been %d minutes since last update" , (timeSinceLastUpdate / 1.minute).round) 
      
      updateShirtWoot()
      updateTeeFury()
      updateRiptApparel()
      updateTheYeTee()
      updateQwertee()
      updateDesignByHumans()
      updateOtherTees()

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
    logInfo "[=> Shirt Woot ====================================]"
    
    shirtwoot_api_url = sprintf("http://api.woot.com/2/events.json?site=shirt.woot.com&eventType=Daily&key=%s", ENV['SHIRTWOOT_API_KEY'] || "")
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
      logError "Error parsing ShirtWoot API"
      logError e.message
    end
  end





  def updateTeeFury
    logInfo "[=> TeeFury =======================================]"

    feed_url = "http://www.teefury.com/rss/rss.xml"
    begin
      feed = Nokogiri::XML(open(feed_url))
      feed.remove_namespaces!

      todaysShirts = Array.new
      feed.xpath("/feed/entry").each do |entry|
        shirtName = entry.xpath("title").first.content
        shirtURL = entry.xpath("link/@href").first.content
        shirtPhotoURL = entry.xpath("content/img/@src").first.content

        todaysShirts.push( find_or_create_Shirt(SITE_ID_TEEFURY, shirtName, shirtURL, shirtPhotoURL) )
      end
      
      record_Success(SITE_ID_TEEFURY, todaysShirts)
    rescue Exception => e
      logError "Error parsing TeeFury feed"
      logError e.message
    end
  end




  def updateRiptApparel
    logInfo "[=> Ript Apparel ==================================]"

    feed_url = "http://feeds.feedburner.com/riptapparel"
    begin
      feed = Nokogiri::XML(open(feed_url))
      feed.remove_namespaces!

      todaysShirts = Array.new
      feed.xpath("/rss/channel/item").take(3).each do |entry|
        shirtName = entry.xpath("title").first.content
        shirtURL = entry.xpath("link").first.content
        entry_description = Nokogiri::HTML( entry.xpath("description").first.content )
        entry_description.remove_namespaces!
        shirtPhotoURL = entry_description.css("img").first["src"]
        
        todaysShirts.push( find_or_create_Shirt(SITE_ID_RIPTAPPAREL, shirtName, shirtURL, shirtPhotoURL) )
      end
      
      record_Success(SITE_ID_RIPTAPPAREL, todaysShirts)
    rescue Exception => e
      logError "Error parsing Ript Apparel feed"
      logError e.message
    end
  end




  def updateTheYeTee
    logInfo "[=> TheYeTee ======================================]"
    feed_url = "http://theyetee.com/feeds/shirts.php"
    begin
      feed = Nokogiri::XML(open(feed_url))
      feed.remove_namespaces!

      todaysShirts = Array.new
      pubDate = feed.xpath("/rss/channel/pubDate").first.content
      feed.xpath("/rss/channel/item").each do |entry|
        shirtName = entry.xpath("title").first.content
        shirtName = shirtName.split(" by ").first || shirtName
        shirtURL = entry.xpath("link").first.content        
        entry_description = Nokogiri::HTML( entry.xpath("description").first.content )
        entry_description.remove_namespaces!
        shirtPhotoURL = entry_description.css("img").first["src"]

        shirtPubDate = entry.xpath("pubDate").first.content

        if pubDate == shirtPubDate
          todaysShirts.push( find_or_create_Shirt(SITE_ID_THEYETEE, shirtName, shirtURL, shirtPhotoURL) )
        end
      end
      
      record_Success(SITE_ID_THEYETEE, todaysShirts)
    rescue Exception => e
      logError "Error parsing TheYeTee feed"
      logError e.message
    end
  end




  def updateQwertee
    logInfo "[=> Qwertee =======================================]"
    feed_url = "http://www.qwertee.com/rss/"
    begin
      feed = Nokogiri::XML(open(feed_url))
      feed.remove_namespaces!

      todaysShirts = Array.new
      pubDate = feed.xpath("/rss/channel/item/pubDate").first.content
      feed.xpath("/rss/channel/item").each do |entry|
        shirtName = entry.xpath("title").first.content
        shirtURL = entry.xpath("link").first.content        
        entry_description = Nokogiri::HTML( entry.xpath("description").first.content )
        entry_description.remove_namespaces!
        shirtPhotoURL = entry_description.css("img").first["src"]

        shirtPubDate = entry.xpath("pubDate").first.content

        if pubDate == shirtPubDate
          todaysShirts.push( find_or_create_Shirt(SITE_ID_QWERTEE, shirtName, shirtURL, shirtPhotoURL) )
        end
      end
      
      record_Success(SITE_ID_QWERTEE, todaysShirts)
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
    feed_url = "http://www.othertees.com/feed/"
    begin
      feed = Nokogiri::XML(open(feed_url))
      feed.remove_namespaces!

      todaysShirts = Array.new
      pubDate = feed.xpath("/rss/channel/item/pubDate").first.content
      feed.xpath("/rss/channel/item").each do |entry|
        shirtName = entry.xpath("title").first.content
        shirtURL = entry.xpath("guid").first.content
        entry_description = Nokogiri::HTML( entry.xpath("description").first.content )
        entry_description.remove_namespaces!
        shirtPhotoURL = entry_description.css("img").first["src"]

        shirtPubDate = entry.xpath("pubDate").first.content

        if pubDate == shirtPubDate
          todaysShirts.push( find_or_create_Shirt(SITE_ID_OTHERTEES, shirtName, shirtURL, shirtPhotoURL) )
        end
      end
      
      record_Success(SITE_ID_OTHERTEES, todaysShirts)
    rescue Exception => e
      logError "Error parsing OtherTees feed"
      logError e.message
    end
  end

end
