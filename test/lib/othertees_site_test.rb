require 'test_helper'
require 'OtherTeesSite'

class OtherTeesSiteTest < ActiveSupport::TestCase
  test "parse valid static" do
    shirts = OtherTeesSite::loadFeedAndExtractShirts('./test/lib/othertees/othertees_valid.xml')

    assert_equal( shirts.length , 1 )
    assert_equal( shirts.first[:siteId] , OtherTeesSite::SITE_ID )
    assert_equal( shirts.first[:shirtName] , "Shuffle and Slice and Not Very Nice" )
    assert_equal( shirts.first[:shirtURL] , "http://www.othertees.com/" )
    assert_equal( shirts.first[:shirtPhotoURL] , "http://www.othertees.com/photos/shop/m_9d5b43b65ba1b7602796032636c11971.PNG" )
  end

  test "can download" do
    json = OtherTeesSite::downloadFeed()
    assert_not_nil(json, "Unable to download ShirtWoot Feed") 
  end

  test "can download and parse live" do
    shirts = OtherTeesSite::downloadFeedAndExtractShirts() 

    assert_not_equal( shirts.length , 0 )
#   shirts.each do |shirt|
#         assert_equal( shirt[:siteId] , OtherTeesSite::SITE_ID )
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtURL] ) ) 
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtPhotoURL] ) )
#     end
  end
end
