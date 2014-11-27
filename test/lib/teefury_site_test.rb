require 'test_helper'
require 'TeeFurySite'

class TeeFurySiteTest < ActiveSupport::TestCase
  test "parse valid static" do
    shirts = TeeFurySite::loadFeedAndExtractShirts('./test/lib/teefury/teefury_valid.xml')

    assert_equal( shirts.length , 1 )
    assert_equal( shirts.first[:siteId] , TeeFurySite::SITE_ID )
    assert_equal( shirts.first[:shirtName] , "Pup Culture" )
    assert_equal( shirts.first[:shirtURL] , "http://www.teefury.com/" )
    assert_equal( shirts.first[:shirtPhotoURL] , "http://www.teefury.com/media/catalog/product/b/-/b-mco-pup-culture_nvy.jpg" )
  end

  test "can download" do
    json = TeeFurySite::downloadFeed()
    assert_not_nil(json, "Unable to download ShirtWoot Feed") 
  end

  test "can download and parse live" do
    shirts = TeeFurySite::downloadFeedAndExtractShirts() 

    assert_not_equal( shirts.length , 0 )
#   shirts.each do |shirt|
#         assert_equal( shirt[:siteId] , ShirtWootSite::SITE_ID )
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtURL] ) ) 
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtPhotoURL] ) )
#     end
  end
end
