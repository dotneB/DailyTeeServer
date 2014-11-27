require 'net/http'
require 'open-uri'

class ShirtWootSite
  SITE_ID = 2

  def self.downloadFeedAndExtractShirts
    return extractShirts( downloadFeed() )
  end

  def self.downloadFeed
    json = downloadDailyFeed()
    if json == nil
      return downloadWootOffFeed()
    end
    return json
  end

  def self.downloadDailyFeed
    shirtwoot_daily_api_url = sprintf("http://api.woot.com/2/events.json?site=shirt.woot.com&eventType=Daily&key=%s", ENV['SHIRTWOOT_API_KEY'] || "")
    networkResponse = Net::HTTP.get_response(URI.parse(shirtwoot_daily_api_url))
    
    if networkResponse.code == "200"
      return JSON.parse(networkResponse.body)
    end

    return nil    
  end

  def self.downloadWootOffFeed
    shirtwoot_wootoff_api_url = sprintf("http://api.woot.com/2/events.json?site=shirt.woot.com&eventType=WootOff&key=%s", ENV['SHIRTWOOT_API_KEY'] || "")
    networkResponse = Net::HTTP.get_response(URI.parse(shirtwoot_wootoff_api_url))
    
    if networkResponse.code == "200"
      return JSON.parse(networkResponse.body)
    end

    return nil    
  end

  def self.loadFeed(filename)
    return JSON.parse(File.read( filename ))
  end

  def self.loadFeedAndExtractShirts(filename)
    return extractShirts( loadFeed(filename) )
  end

  def self.extractShirts(json)
    shirts = Array.new

    if json and json.first and json.first['Offers']
      json.first['Offers'].each do |offer|
        shirtName = offer['Title']
        shirtURL = offer['Url']
        shirtPhotoURL = offer['Photos'].select{|photo| photo['Tags'].include?('gallery')}.take(2).last['Url']

        shirts.push( { :siteId => SITE_ID, :shirtName => shirtName, :shirtURL => shirtURL, :shirtPhotoURL => shirtPhotoURL } )
      end
    end

    return shirts
  end
end