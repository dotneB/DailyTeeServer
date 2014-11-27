require 'test_helper'
require 'QwerteeSite'

class QwerteeSiteTest < ActiveSupport::TestCase
  test "parse valid static" do
    shirts = QwerteeSite::loadFeedAndExtractShirts('./test/lib/qwertee/qwertee_valid.xml')

    assert_equal( shirts.length , 1 )
    assert_equal( shirts.first[:siteId] , QwerteeSite::SITE_ID )
    assert_equal( shirts.first[:shirtName] , "The Making of a Heisenberg" )
    assert_equal( shirts.first[:shirtURL] , "http://www.qwertee.com/" )
    assert_equal( shirts.first[:shirtPhotoURL] , "http://www.qwertee.com/images/designs/zoom/30626.jpg" )
  end

  test "can download" do
  	json = QwerteeSite::downloadFeed()
    assert_not_nil(json, "Unable to download ShirtWoot Feed") 
  end

  test "can download and parse live" do
    shirts = QwerteeSite::downloadFeedAndExtractShirts() 

    assert_not_equal( shirts.length , 0 )
#   shirts.each do |shirt|
#         assert_equal( shirt[:siteId] , QwerteeSite::SITE_ID )
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtURL] ) ) 
#     assert_nothing_raised( URI::InvalidURIError, URI.parse( shirt[:shirtPhotoURL] ) )
#     end
  end
end
