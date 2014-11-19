require 'net/http'
require 'open-uri'
require 'test_helper'
require 'ShirtWootSite'

class ShirtWootSiteTest < ActiveSupport::TestCase
  test "parse valid static" do
    shirtwootcom_valid = File.read('./test/lib/shirtwoot/shirtwootcom_valid.json')
    json = JSON.parse(shirtwootcom_valid)

    shirts = ShirtWootSite::extractShirts(json)

    assert_equal( shirts.length , 1 )
    assert_equal( shirts.first[:siteId] , ShirtWootSite::SITE_ID )
    assert_equal( shirts.first[:shirtName] , "Cupcake Science" )
    assert_equal( shirts.first[:shirtURL] , "http://shirt.woot.com/offers/cupcake-science-1?utm_source=version2&utm_medium=json&utm_campaign=api.woot.com" )
    assert_equal( shirts.first[:shirtPhotoURL] , "http://d3gqasl9vmjfd8.cloudfront.net/d967d1d6-4f96-404a-b33b-151b48708171.png" )
  end

  test "can download" do
    json = ShirtWootSite::downloadFeed()
    assert_not_nil(json, "Unable to download ShirtWoot Feed") 
  end

  test "can download and parse live" do
    shirts = ShirtWootSite::downloadFeedAndExtractShirts() 

    assert_not_equal( shirts.length , 0 )
#   shirts.each do |shirt|
#         assert_equal( shirt[:siteId] , ShirtWootSite::SITE_ID )
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtURL] ) ) 
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtPhotoURL] ) )
#     end
  end
end
