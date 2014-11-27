require 'nokogiri'

class TheYeTeeSite
  SITE_ID = 5

  def self.downloadFeedAndExtractShirts
    return extractShirts( downloadFeed() )
  end

  def self.downloadFeed
    feed = Nokogiri::XML(open("http://theyetee.com/feeds/shirts.php"))
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

    pubDate = xml.xpath("/rss/channel/pubDate").first.content
    
    xml.xpath("/rss/channel/item").each do |entry|
      shirtName = entry.xpath("title").first.content
      shirtName = shirtName.split(" by ").first || shirtName
      shirtURL = "http://theyetee.com/"
      #entry_description = Nokogiri::HTML.fragment( entry.xpath("description").first.content )
      #entry_description.remove_namespaces!
      #shirtPhotoURL = entry_description.css("img").first["src"]
      shirtPhotoURL = entry.xpath("description").first.content[ /img.*?src="(.*?)"/i,1 ].to_s

      shirtPubDate = entry.xpath("pubDate").first.content

      if pubDate == shirtPubDate and shirtPhotoURL.include? "/A_"
        shirts.push( { :siteId => SITE_ID, :shirtName => shirtName, :shirtURL => shirtURL, :shirtPhotoURL => shirtPhotoURL } )
      end
    end

    return shirts
  end
end