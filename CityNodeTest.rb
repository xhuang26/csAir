require_relative "CityNode"
require "test/unit"

class CityNodeTest < Test::Unit::TestCase
  #test is the CityNode can be initialized correctly
  def test_initializeNode
    node = CityNode.new("code", "name", "country", "continent", "timezone", {"N"=>"32", "S" =>"25"}, "population", "region")
    assert_equal("name", node.name)
    assert_equal("code", node.code)
    assert_equal("country", node.country)
    assert_equal("continent", node.continent)
    assert_equal("timezone", node.timezone)
    assert_equal("32 N 25 S ", node.coordinates)
    assert_equal("population", node.population)
    assert_equal("region", node.region)
    destinationsType = node.destinations.instance_of? Hash
    assert_equal(destinationsType, true)
  end
  
  #if addDest function work correctly
  def test_addDest
    node = CityNode.new("code", "name", "country", "continent", "timezone", {"N"=>"32", "S" =>"25"}, "population", "region")
    destCode = "code1"
    destDist = 100
    node.addDest(destCode, destDist)
    assert_equal(node.destinations.length, 1)
    assert_equal(node.destinations[destCode.to_sym], destDist)
  end
end
