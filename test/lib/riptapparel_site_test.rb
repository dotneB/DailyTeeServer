require 'test_helper'
require 'RiptApparelSite'

class RiptApparelSiteTest < ActiveSupport::TestCase
  test "parse valid static" do
    shirts = RiptApparelSite::loadFeedAndExtractShirts('./test/lib/riptapparel/riptapparel_valid.xml')

    assert_equal( shirts.length , 3 )
    assert_equal( shirts.first[:siteId] , RiptApparelSite::SITE_ID )
    assert_equal( shirts.first[:shirtName] , "Bite and Fight" )
    assert_equal( shirts.first[:shirtURL] , "http://feedproxy.google.com/~r/riptapparel/~3/rCbybSQbIL4/" )
    assert_equal( shirts.first[:shirtPhotoURL] , "https://uploads-riptapparel-com.s3.amazonaws.com/products/20705-mens-141127-3.3918.png" )
  end

  test "can download" do
    json = RiptApparelSite::downloadFeed()
    assert_not_nil(json, "Unable to download ShirtWoot Feed") 
  end

  test "can download and parse live" do
    shirts = RiptApparelSite::downloadFeedAndExtractShirts() 

    assert_not_equal( shirts.length , 0 )
#   shirts.each do |shirt|
#         assert_equal( shirt[:siteId] , ShirtWootSite::SITE_ID )
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtURL] ) ) 
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtPhotoURL] ) )
#     end
  end
end
