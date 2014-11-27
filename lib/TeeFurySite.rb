require 'nokogiri'

class TeeFurySite
  SITE_ID = 3

  def self.downloadFeedAndExtractShirts
    return extractShirts( downloadFeed() )
  end

  def self.downloadFeed
    feed = Nokogiri::XML(open("http://www.teefury.com/rss/rss.xml"))
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

    xml.xpath("/feed/entry").each do |entry|
      shirtName = entry.xpath("title").first.content
      shirtURL = "http://www.teefury.com/"
      shirtPhotoURL = entry.xpath("content").first.content[ /img.*?src="(.*?)"/i,1 ].to_s

      shirts.push( { :siteId => SITE_ID, :shirtName => shirtName, :shirtURL => shirtURL, :shirtPhotoURL => shirtPhotoURL } )
    end

    return shirts
  end
end