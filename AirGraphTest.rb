require_relative "AirGraph"
require_relative "CityNode"
require "test/unit"

class AirGraphTest < Test::Unit::TestCase
  #test graph can be initialized correctly with one node
  def test_fillCityInMapOneNode
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "code", "name"=>"name", "country"=>"country", "continent"=>"continent", "timezone"=>"timezone", "coordinates"=>{"S"=>"25", "W"=>"15"}, "population"=>"152", "region"=>"3"}]}
    map = graph.fillCityInMap(data, graph.map)
    node = map["code"]
    nodeType = node.instance_of? CityNode
    assert_equal(map.length, 1)
    assert_equal(nodeType, true)
    assert_equal(node.code, "code") 
  end
  
  #test if graph can be initialized correctly with more than one noes
  def test_fillCityInMapMultipleNodes
      graph = AirGraph.new()
      data = {"metros" => [{"code"=> "code", "name"=>"name", "country"=>"country", "continent"=>"continent", "timezone"=>"timezone", "coordinates"=>{"S"=>"25", "W"=>"15"}, "population"=>"152", "region"=>"3"}, {"code"=> "code1", "name"=>"name1", "country"=>"country1", "continent"=>"continent1", "timezone"=>"timezone1", "coordinates"=>{"S"=>"25", "W"=>"15"}, "population"=>"152", "region"=>"3"}]}
      map = graph.fillCityInMap(data, graph.map)
      node = map["code"]
      node1 = map["code1"]
      nodeType = node.instance_of? CityNode
      node1Type = node.instance_of? CityNode
      assert_equal(map.length, 2)
      assert_equal(nodeType, true)
      assert_equal(node1Type, true)
      assert_equal(node.code, "code") 
      assert_equal(node1.code, "code1") 
    end
  
  #test is new city connections can successifully added to the map and distanceMap
  def test_addCityConnection
    graph = AirGraph.new()
    sclSym = "SCL"
    limSym = "LIM"
    graph.map = {sclSym => CityNode.new("SCL", "name", "country", "continent", "timezone", {"N"=>"32", "S" =>"25"}, "population", "region"), limSym =>CityNode.new("LIM", "name", "country", "continent", "timezone", {"N"=>"32", "S" =>"25"}, "population", "region")}
    data = {"routes" => [{"ports"=>["SCL", "LIM"], "distance"=>2453}]}
    graph.addCityConnection(data, graph.map, graph.distanceMap)
    assert_equal(graph.map[sclSym].destinations.length, 1)
    assert_equal(graph.map[sclSym].destinations.keys[0], limSym)
    assert_equal(graph.map[sclSym].destinations[limSym], 2453)
    assert_equal(graph.distanceMap["SCL LIM"], 2453)
    assert_equal(graph.distanceMap["LIM SCL"], 2453)
  end

  #test if the city with largest population can be returned correctly
  def test_largestPopulation
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "population"=>1}, {"code"=> "B", "population"=>2}, {"code"=> "C", "population"=>3}]}
    map = graph.fillCityInMap(data, graph.map)
    nodes = graph.findCityByPopluation(true)
    assert_equal(nodes.length, 1)
    assert_equal(nodes[0].code, "C")
  end
  
  #test if the city with smallest population can be returned correctly
  def test_smallestPopulation
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "population"=>1}, {"code"=> "B", "population"=>2}, {"code"=> "C", "population"=>3}]}
    map = graph.fillCityInMap(data, graph.map)
    nodes = graph.findCityByPopluation(false)
    assert_equal(nodes.length, 1)
    assert_equal(nodes[0].code, "A")
  end
  
  # test if the largest population can be returned succesfully when there are two cities wth same population
  def test_largestPopulationWithSamePopu
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>2}]}
    map = graph.fillCityInMap(data, graph.map)
    nodes = graph.findCityByPopluation(true)
    assert_equal(nodes.length, 2)
    assert_equal(nodes[0].code, "B")
    assert_equal(nodes[1].code, "C")
  end
  
  #test if the average population is returned correctly
  def test_averagePopulation
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}]}
    map = graph.fillCityInMap(data, graph.map)
    average = graph.findAvgByPopulation()
    assert_equal(average, 2)
  end
  
  #test if the average distance is returned correctly
  def test_averageDistance
    graph = AirGraph.new()
    graph.distanceMap = {"A B"=>1, "B C"=>2, "C D"=>3}
    avg = graph.findAvgByDistance()
    assert_equal(avg, 2)
  end
  
  #test if the cities with largest distance is returned correctly
  def test_findCitiesWithMaxDist
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1}, {"ports"=> ["B", "C"], "distance"=>2}, {"ports"=> ["A", "C"], "distance"=>3}]}
    graph.fillData(data)
    max = graph.findCityByDistance(true)
    assert_equal(max["city1"], "A")
    assert_equal(max["city2"], "C")
    assert_equal(max["dist"], 3) 
  end
  
  #test if the continents included in the data is all been detected and listed out
  def test_listContinents
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "continent"=>"Asia"}, {"code"=> "B", "name"=>"B", "continent"=>"Asia"}, {"code"=> "C",  "name"=>"C", "continent"=>"Europe"}]}
    graph.fillCityInMap(data, graph.map)
    continents = graph.listContinents()
    assert_equal(continents["Asia"], "A | B")
    assert_equal(continents["Europe"], "C")
  end
  
  #check is the hub cities is dectected and listed correctly
  def test_hubs
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1}, {"ports"=> ["B", "C"], "distance"=>3}]}
    graph.fillData(data)
    hubCities = graph.listHubs()
    assert_equal(hubCities, "B")
  end
  
  #test if  removeRoute function works appropriately
  def test_removeRoute
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1}, {"ports"=> ["B", "C"], "distance"=>3}]}
    graph.fillData(data)
    ifSucceed = graph.removeRoute("A","B")
    assert_equal(ifSucceed, true)
    assert_equal(graph.distanceMap["B A"], 1)
    assert_equal(graph.distanceMap["C B"], 3)
    assert_equal(graph.distanceMap["B C"], 3)
    assert_equal(graph.distanceMap["A B"], nil)
  end
  
  # test if removeCity function works approriately
  def test_removeCity
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1}, {"ports"=> ["B", "C"], "distance"=>3}]}
    graph.fillData(data)
    ifSucceed = graph.removeCity("A")
    assert_equal(graph.map["A"], nil)
    assert_equal(graph.distanceMap["C B"], 3)
    assert_equal(graph.distanceMap["B C"], 3)
    assert_equal(graph.distanceMap["A B"], nil)
    assert_equal(graph.distanceMap["B A"], nil)   
  end
  
  #test if add city function works appropriately
  def test_addCity
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1}, {"ports"=> ["B", "C"], "distance"=>3}]}
    graph.fillData(data)
    ifSucceed = graph.addCity("D B","D","country1","Africa", -1, {"N"=>1, "E"=>1},100,"D")
    assert_equal(ifSucceed, true)
    assert_equal(graph.map["DB"].code, "DB")
    assert_equal(graph.map["DB"].name, "D")
    assert_equal(graph.map["DB"].country, "country1")
    assert_equal(graph.map["DB"].continent, "Africa")
    assert_equal(graph.map["DB"].timezone, -1)
    assert_equal(graph.map["DB"].coordinates, "1 N 1 E ")
    assert_equal(graph.map["DB"].population, 100)  
    assert_equal(graph.map["DB"].region, "D")
  end
  
  #test if error is catched when add illegal info for the city
  #test if purifyInput function works
  def test_addCityIllegalInfo
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1}, {"ports"=> ["B", "C"], "distance"=>3}]}
    graph.fillData(data)
    ifSucceed = graph.addCity("D B","D","country1","error", -1, {"N"=>1, "E"=>1},100,"D")
    assert_equal(ifSucceed, false)
    ifSucceed = graph.addCity("D B","D","country1","Africa", -100, {"N"=>1, "E"=>1},100,"D")
    assert_equal(ifSucceed, false)
    ifSucceed = graph.addCity("D B","D","country1","Africa", -1, {"K"=>1, "E"=>1},100,"D")
    assert_equal(ifSucceed, false)
    ifSucceed = graph.addCity("D B","D","country1","Africa", -1, {"N"=>1, "E"=>1},-10,"D")
    assert_equal(ifSucceed, false)
  end
  
  #test if route can be sucessifully added
  def test_addRoute
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1}, {"ports"=> ["B", "C"], "distance"=>3}]}
    graph.fillData(data)
    ifSucceed = graph.addRoute("A", "C", 100)
    assert_equal(ifSucceed, true)
    assert_equal(graph.distanceMap["A C"], 100)
    assert_equal(graph.distanceMap["C A"], nil)
  end
  
  #test city can be edit approriately
  def test_editCity
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1}, {"ports"=> ["B", "C"], "distance"=>3}]}
    graph.fillData(data)
    ifSucceed = graph.editCity("name", "editA", "A")
    assert_equal(ifSucceed, true)
    assert_equal(graph.map['A'].name, "editA")
  end
  
  def test_getRouteInfo
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1}, {"ports"=> ["B", "C"], "distance"=>3}]}
    graph.fillData(data)
    route = "A,B,C"
    info = graph.getRouteInfo(route)
    assert_equal(info['dist'], 4)#1+3
    assert_equal(info['cost'], 1.25)#0.35*1+0.3*3
    assert_equal(info['time'].round(2), 3.95)#sqrt(1*2/1225)+2+sqrt(3*2/1225)+(2-1/6)
  end
  
  #test if findShortestPath function works
  def test_findShortestPath
    graph = AirGraph.new()
    data = {"metros" => [{"code"=> "A", "name"=>"A", "population"=>1}, {"code"=> "B", "name"=>"B", "population"=>2}, {"code"=> "C",  "name"=>"C", "population"=>3}], "routes" => [{"ports"=> ["A", "B"], "distance"=>1, "routeStatus"=>1}, {"ports"=> ["B", "C"], "distance"=>3, "routeStatus"=>1}, {"ports"=> ["A", "C"], "distance"=>5, "routeStatus"=>1}]}
    graph.fillData(data)
    routeString = findShortestPath("A", "C")
    assert_equal(routeString, "A,B,C")
  end
end