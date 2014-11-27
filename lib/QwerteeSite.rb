require 'nokogiri'

class QwerteeSite
  SITE_ID = 6

  def self.downloadFeedAndExtractShirts
    return extractShirts( downloadFeed() )
  end

  def self.downloadFeed
    feed = Nokogiri::XML(open("https://www.qwertee.com/rss/"))
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

    pubDate = xml.xpath("/rss/channel/item/pubDate").first.content
    xml.xpath("/rss/channel/item").each do |entry|
      shirtName = entry.xpath("title").first.content
      shirtURL = entry.xpath("link").first.content        
      entry_description = Nokogiri::HTML( entry.xpath("description").first.content )
      entry_description.remove_namespaces!
      shirtPhotoURL = entry_description.css("img").first["src"]

      shirtPubDate = entry.xpath("pubDate").first.content

      if pubDate == shirtPubDate
        shirts.push( { :siteId => SITE_ID, :shirtName => shirtName, :shirtURL => shirtURL, :shirtPhotoURL => shirtPhotoURL } )
      end
    end

    return shirts
  end
end