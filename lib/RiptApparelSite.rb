require 'nokogiri'

class RiptApparelSite
  SITE_ID = 3

  def self.downloadFeedAndExtractShirts
    return extractShirts( downloadFeed() )
  end

  def self.downloadFeed
    feed = Nokogiri::XML(open("http://feeds.feedburner.com/riptapparel"))
    feed.remove_namespaces!

    return feed
  end

  def self.loadFeed(filename)
    feed = Nokogiri::XML(File.read( filename ))
    feed.remove_namespaces!
    return feed
  end

  def self.loadFeedAndExtractShirts(filename)
    return extractShirts( loadFeed(filename) )
  end

  def self.extractShirts(xml)
    shirts = Array.new

    xml.xpath("/rss/channel/item").take(3).each do |entry|
      shirtName = entry.xpath("title").first.content
      shirtURL = entry.xpath("link").first.content
      entry_description = Nokogiri::HTML( entry.xpath("description").first.content )
      entry_description.remove_namespaces!
      shirtPhotoURL = entry_description.css("img").first["src"]
      
      shirts.push( { :siteId => SITE_ID, :shirtName => shirtName, :shirtURL => shirtURL, :shirtPhotoURL => shirtPhotoURL } )
    end

    return shirts
  end
end