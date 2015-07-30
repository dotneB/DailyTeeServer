require 'test_helper'
require 'TheYeTeeSite'

class TheYeTeeSiteTest < ActiveSupport::TestCase
  test "parse valid static" do
    shirts = TheYeTeeSite::loadFeedAndExtractShirts('./test/lib/theyetee/theyetee_valid.xml')

    assert_equal( shirts.length , 1 )
    assert_equal( shirts.first[:siteId] , TheYeTeeSite::SITE_ID )
    assert_equal( shirts.first[:shirtName] , "CatchEm Holiday" )
    assert_equal( shirts.first[:shirtURL] , "http://theyetee.com/" )
    assert_equal( shirts.first[:shirtPhotoURL] , "http://theyetee.com/shirt_images/SF35-Pokemas/A_pokemas.jpg" )
  end

#  test "can download" do
#    json = TheYeTeeSite::downloadFeed()
#    assert_not_nil(json, "Unable to download ShirtWoot Feed") 
#  end
#
#  test "can download and parse live" do
#    shirts = TheYeTeeSite::downloadFeedAndExtractShirts() 
#
#    assert_not_equal( shirts.length , 0 )
##   shirts.each do |shirt|
##         assert_equal( shirt[:siteId] , ShirtWootSite::SITE_ID )
##     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtURL] ) ) 
##     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtPhotoURL] ) )
##     end
#  end
end
