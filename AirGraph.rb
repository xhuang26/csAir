require "rubygems"
require "json"
require_relative "CityNode"


class AirGraph
  #expose two parameters to textInterface
  attr_accessor(:map, :distanceMap)
  
  #initalize the map and distancemap
  def initialize
    @map = Hash.new
    @distanceMap = Hash.new   
  end
 

   
=begin
  param: data
  fill data in two maps
=end
  def fillData(data)  
    fillCityInMap(data, @map)
    addCityConnection(data, @map, @distanceMap)  
  end
  
  
=begin
  param: data, map
  help fill data in map
  each key is a city code and the value is a CityNode
  if the code already exist, the info will be updated
=end
  def fillCityInMap(data, map)
    data["metros"].each do |city|
      code = city["code"]
      cityNode = CityNode.new(city["code"],city["name"],city["country"],city["continent"],city["timezone"],city["coordinates"], city["population"],city["region"])
      map[code] = cityNode
    end
    return map
  end
  
=begin
  get city code by using name
=end
  def getCode(name)
    @map.each do |code, cityNode|
      if(cityNode.name == name)
        return cityNode
      end
    end
    return nil
  end
  
=begin
  looping the data to add connection in both map and distancemap
  distancemap will have distance as key, an array as value with two cities inside
=end
  def addCityConnection(data, map, distanceMap)
    data["routes"].each do |route|
      codes = route["ports"]
      
      dist = route["distance"]
      status = route["routeStatus"]
      if(codes.size != 2)
        raise "invalid ports size"
      end
      codePair1 = setDistanceMapKey(codes[0], codes[1])
      codePair2 = setDistanceMapKey(codes[1], codes[0])
      if(status == nil || status == 2)
        node2 = map[codes[1]]
        node2.addDest(codes[0], dist)
        distanceMap[codePair2] = dist
      end
      node1 = map[codes[0]]
      node1.addDest(codes[1], dist) 
      distanceMap[codePair1] = dist
      
    end
   return
  end

=begin
  param: code1, code2
  passing two code, get the key string from it
=end
  def setDistanceMapKey(code1, code2)
    return code1+" "+code2
  end  
  
=begin
  param: key
  get a array of two city code inside based on the key passed in
=end
  def parseDistanceMapKey(key)
    return key.split(" ")
  end
  
  
=begin
  param: city1, city2
  remove a flight
=end
  def removeRoute(city1, city2)
    code1 = getCode(city1).code
    code2 = getCode(city2).code
    if(code1 != nil && code2 != nil)
      key = setDistanceMapKey(code1, code2)
      if(@distanceMap.delete(key) == nil)
        return false
      end
      @map[code1].destinations.delete(code2)
      return true
    end
    return false
  end

=begin
  get all keys include the target keycode
=end
  def getKeycodes(code)
    codesArray = Array.new
    @distanceMap.each do |codes, dist|
      if codes.include? code
        codesArray.push(codes)
      end
    end
    return codesArray
  end
 
=begin
  param: city
  remove a city
=end
  def removeCity(city)
    node = getCode(city)
    if(node != nil)
      code = node.code
      codesArray = getKeycodes(code)
      for codes in codesArray
        codesPair = parseDistanceMapKey(codes)
        @distanceMap.delete(codes)
        map[codesPair[0]].destinations.delete(codesPair[1])
      end
      @map.delete(code)
      return true
    else
      return false
    end
  end
  
=begin
  param: code, name, country, continent, timezone, coordinates, population, region
  add a city
=end
  def addCity(code, name, country, continent, timezone, coordinates, population, region)
    if(map[code] != nil)
      return false
    end
    codePair = purifyInput("code", code)
    namePair = purifyInput("name", name)
    countryPair = purifyInput("country", country)
    continentPair = purifyInput("continent", continent)
    timezonePair = purifyInput("timezone", timezone)
    coordinatesPair = purifyInput("coordinates", coordinates)
    populationPair = purifyInput("population", population)
    regionPair = purifyInput("region", region)
    if(codePair != nil && namePair != nil && countryPair != nil && continentPair != nil && timezonePair != nil && coordinatesPair != nil && populationPair != nil && regionPair != nil)
      cityNode = CityNode.new(codePair['value'],namePair['value'],countryPair['value'],continentPair['value'],timezonePair['value'],coordinatesPair['value'], populationPair['value'], regionPair['value'])
      code = cityNode.code
      map[code] = cityNode
      return true
    end
    return false
  end
  
=begin
  param: city1, city2, des
  add a route
=end
  def addRoute(city1, city2, des)
    code1 = getCode(city1).code
    code2 = getCode(city2).code
    if(code1 == nil || code2 == nil)
      return false
    end
    key = setDistanceMapKey(code1, code2)
    if(@distanceMap[key] != nil)
      return false
    end
    @distanceMap[key] = des
    @map[code1].destinations[code2] = des
    return true
  end


=begin
  param: value
  check if the current value is a number or the string is actually a int with qoute
=end 
def is_i?(value)
  (value.is_a? Numeric) || (/\A[-+]?\d+\z/ === value)
end

=begin
  param: parsed
  parse the passed in key-value coordiantes pair as string
=end
  def parseCoords(parsed)
    coordString = ""
    directions = parsed.keys
    directions.each do |dir|
      newString = parsed[dir].to_s + ' ' + dir + ' '
      coordString = coordString + newString
    end
    return coordString
  end
  
=begin
  param: key, value
  purify the input
  return nil if failed to purify
=end  
  def purifyInput(key, value)
    if(key == 'code')
      value = value.gsub(/\s+/, "")
    elsif(key == 'continent')
      if(!['Africa', 'Antarctica', 'Asia', 'Australia', 'Europe', 'North America', 'South America'].include? value)
        return nil
      end
    elsif(key == 'timezone')
      if(is_i?(value))
        value = value.to_i
        if(value < -8 || value > 8)
          return nil
        end
      else
        return nil
      end
    elsif(key == 'coordinates')
      key1 = value.keys[0]
      key2 = value.keys[1]
      if((key1 != 'N' && key1 != 'S') || (key2 != 'W' && key2 != 'E'))
        return nil
      end
      if(is_i?(value[key1]))
        value[key1] = value[key1].to_i
        if(value[key1] < 0 || value[key1] > 90)
         return nil
        end
      else
        return nil
      end
      if(is_i?(value[key2]))
        value[key2] = value[key2].to_i
        if(value[key2] < 0 || value[key2] > 180)
          return nil
        end 
      else
        return nil  
      end 
      value = parseCoords(value)
    elsif(key == 'population')
      if(is_i?(value))
        value = value.to_i
        if(value < 0)
          return nil
        end
      else
        return nil
      end
    end
    return {'key' => key, 'value' => value}
  end  
  
=begin
  edit city info
country, continent, timezone, coordinates, population, region
=end
  def editCity(key, value, city)
    node = getCode(city)
    if(node == nil)
      return false
    end
    result = purifyInput(key, value)
    if(result == nil)
      return false
    end
    node.setValue(key, result['value'], node)
    return true
  end
  
=begin
  param: name
  get city info stored in the map by searching with name
=end
  def getCityInfo(name)
    cityNode = getCode(name)
    if(cityNode == nil)
      return false
    else
      puts " Code: #{cityNode.code}\n Name: #{cityNode.name}\n Country: #{cityNode.country}\n Continent: #{cityNode.continent}\n Timezone: #{cityNode.timezone}\n Coordinates: #{cityNode.coordinates}\n Population: #{cityNode.population} \n Reigion: #{cityNode.region}\n"
      listCities(cityNode.destinations)
      return true
    end
  end
 
=begin
  if the param is array of city code, get all info of cities inside the array
  if no param is passed, get all cities
=end 
  def listCities(*args)
    cities = " Avaialble Destinations: "
    isFirst = true;
    if(args.size == 1)
      codes = args[0]
      codes.each do |code, distance|
         cityNode = @map[code] 
         if(isFirst)
           cities = cities + cityNode.name + ": "+ distance.to_s + "km"
           isFirst = false;
         else
           cities = cities + " | " + cityNode.name + ": "+ distance.to_s + "km"
         end
      end
    else
      cities = ""
      @map.each do |code, cityNode|
        if(isFirst)
          cities = cities + cityNode.name
          isFirst = false;
        else
          cities = cities + " | " +  cityNode.name
        end
      end    
    end
    puts cities
  end
  
  
=begin
  param: boolean tryFindBiggest
  find either the biggest or smallest city by population
=end
  def findCityByPopluation(tryFindBiggest)
    popu = -1
    nodes = Array.new()
    text = ""
    if(tryFindBiggest)
      @map.each do |code, cityNode|
        if(cityNode.population > popu)
          nodes.clear()
          nodes.push(cityNode)
          popu = cityNode.population
        elsif(cityNode.population == popu)
          nodes.push(cityNode)
        end
      end
      text = "max"
    else
      @map.each do |code, cityNode|
        if(popu == -1 or cityNode.population < popu)
          nodes.clear()
          nodes.push(cityNode)
          popu = cityNode.population
        elsif(cityNode.population == popu)
          nodes.push(cityNode)
        end
      end
      text = "min"
    end
    if(nodes.length != 0)
      puts("\nCity with " + text + " population is: \n")
      nodes.each do |node|
        getCityInfo(node.name)
      end
    end
    return nodes
  end
  
  
=begin
  find average population over all cities
=end
  def findAvgByPopulation()
    total = 0
    nums = 0
   @map.each do |code, cityNode|
    total = total + cityNode.population
    nums = nums+1
   end
    puts("\nAverage population for all cities is: #{total/nums}\n")
    return total/nums
  end
  
  
=begin
  find average distance over all cities
=end
 def findAvgByDistance()
    dists = @distanceMap.values.sort()
    avg = dists.inject{ |sum, el| sum + el } / dists.size
    puts("\nAverage distance for all cities is: #{avg}\n")
    return avg
  end
  
  
=begin
  param: boolean tryingFindMax
  try find two cities with either longest distance or shortest distance
=end
  def findCityByDistance(tryingFindMax)
    sortedMap = @distanceMap.sort_by{|k,v| v}.to_h
    key, dist = sortedMap.first
    cities = parseDistanceMapKey(key)
    text = "min"
    if(tryingFindMax)
      key = sortedMap.keys.last
      cities = parseDistanceMapKey(key)
      dist = sortedMap[key]
      text = "max"
    end
    city1 = @map[cities[0]].name
    city2 = @map[cities[1]].name
    puts "\nThe "+ text + " distance is " + dist.to_s + " between "+ city1 + " " + city2 +"\n";
    return {"city1"=>city1, "city2"=>city2, "dist"=>dist}
  end
  
=begin
  list all continents CS air flies to
=end
  def listContinents
    continents = Hash.new()
    @map.each do |code, cityNode|
      if(continents[cityNode.continent] == nil)
        continents[cityNode.continent] = "#{cityNode.name}"
      else
        continents[cityNode.continent] = continents[cityNode.continent]+" | #{cityNode.name}"
      end
    end
    puts "\nContinents we flight to:\n"
    continents.each do |continent, string|
      puts "#{continent}: #{string}"
    end
    return continents
  end
  
=begin
  list all the hub cities
=end
  def listHubs()
    hubCities = ""
    max = 0;
    @map.each do |code, cityNode|
      if(cityNode.destinations.size > max)
        hubCities = "#{cityNode.name}"
        max = cityNode.destinations.size
      elsif(cityNode.destinations.size == max)
        hubCities = hubCities + " | #{cityNode.name}"
      end
    end
    puts "\nhub cities: #{hubCities}"
    puts "\nnumber of connections in hub cities: #{max}\n"
    return hubCities
    return
  end
 
=begin
  open website
=end 
  def getUrl()
    url = "http://www.gcmap.com/search?Q="
    @distanceMap.each do |key, dist|
      codes = parseDistanceMapKey(key)
      code1 = codes[0]
      code2 = codes[1]
      urlCode = "+#{code1}-#{code2},"
      url = url+urlCode
    end
    url = url[0..-2]
    system("open", url)
  end
  
=begin
  create json file based on current graph
=end 
  def createJSON()
    object = {"metros"=>[], "routes"=>[]}
    #get metros info
    @map.each do |code, node|
      coordsArray = node.coordinates.split(" ")
      coordinates = {coordsArray[1]=>coordsArray[0], coordsArray[3]=>coordsArray[2]}
      curObj = {"code" => code, "name" => node.name, "contry"=>node.country, "continent"=>node.continent, "timezone"=>node.timezone, "population"=>node.population, "region" => node.region, "coordinates"=> coordinates}
      object['metros'].push(curObj) 
    end
    
    #get ports info
    addedCodes = Array.new()
    @distanceMap.each do |codes, dis|
      codesArray = parseDistanceMapKey(codes)
      codesArrayReverse = codesArray.reverse
      codesReverse = setDistanceMapKey(codesArrayReverse[0], codesArrayReverse[1])
      if((addedCodes.include? codes) == false)
        curObj = {"ports"=>codesArray, "distance"=>dis, "routeStatus"=>1}
        if(@distanceMap.has_key?(codesReverse))
          addedCodes.push(codesReverse)
          curObj["routeStatus"] = 2
        end  
        object['routes'].push(curObj)
        addedCodes.push(codes)
      end
    end
    return object
  end
  
=begin
  param: route
  get info about a route
  return object with cost, time, distance about the current route
=end
  def getRouteInfo(route)
    cities = route.split(",")
    dist = 0
    cost = 0
    unitPrice = 0.35
    distance = 0
    #V1^2-V0^2 = 2as
    acceleration = (700.0**2)/(2*200.0)
    time = 0
    if(cities.length < 1)
      return {"dist"=>dist, "cost"=>cost, "time"=>time}
    end
    prev = nil
    isFirst = true
    for curCity in cities
      node = getCode(curCity)
      #check if node exist
      if(node == nil)
        return nil
      end 
      if(!isFirst) 
        codes = setDistanceMapKey(prev, node.code)
        if (@distanceMap.has_key?(codes))
          #dist
          curDist = @distanceMap[codes]
          dist = dist + curDist
          #cost
          cost = cost + unitPrice*curDist
          temp = unitPrice-0.05
          unitPrice = (temp>0)?temp:0
          #time
          if(dist < 400)
            #s = 0.5*a*t^2
            t= Math.sqrt(dist*2/acceleration)
            time = time + t
          else
            time = time + Math.sqrt((400*2)/acceleration) + (dist-400)/750
          end
          outBounds = @map[prev].destinations.length
          temp = 2 - (1.0/6)*(outBounds-1)
          layover = (temp>0)?temp:0
          time = time+layover
        else
          return nil
        end
        prev = node.code
      else
        prev = node.code
        isFirst = false
      end  
    end
    return {"dist"=>dist, "cost"=>cost.round(2), "time"=>time.round(2)}
  end

=begin
  param: code, visited, dist, prevCode
  helper for creating path node
=end 
  def createPathNode(code, visited, dist, prevCode)
    return {"code"=>code, "visited"=>visited, "dist"=>dist, "prevCode"=>prevCode}
  end
  
=begin
  implemnet Dijkstra's algorithm
=end
  def findShortestPath(city1, city2)
    node1 = getCode(city1)
    node2 = getCode(city2)
    if(node1 == nil || node2 == nil)
      return nil
    end
    #start with city1
    startNode = createPathNode(node1.code, false, 0, nil)
    hash = {node1.code =>startNode}#for storing the unvisited pathNodes
    totalHash = {node1.code =>startNode}#for storing all the pathNodes
    
    while(hash.length != 0 )
      #sort
      hash = hash.sort_by{|k,v| v["dist"]}.to_h
      #pop
      curCode = hash.keys[0]
      curPathNode = hash.delete(curCode)
      neighbors = @map[curCode].destinations
      #loop destinations
      neighbors.each do |code, dis|
        codes = setDistanceMapKey(curCode, code)
        directDis = @distanceMap[codes]
        alt = directDis + curPathNode["dist"]
        if(totalHash.has_key?(code))#if in totalHash, check if visited, then compare path
          pathNode = totalHash[code]
          if(pathNode['visited'] == true)
            next
          else
            if(alt < pathNode["dist"])
              pathNode["dist"] = alt
              pathNode["prevCode"] = curCode
            end
          end
        else #if not exist, create a new path node, add it to both hash and totalhash
          pathNode = createPathNode(code, false, alt, curCode)
          hash[code] = pathNode
          totalHash[code] = pathNode
        end
      end
      curPathNode["visited"] = true
    end
    
    #check if the city2 is actually visited
    curPathNode = totalHash[node2.code]
    if(curPathNode["visited"] == false)
      return nil
    end
    
    #trace back to find the routeString
    routeString = city2
    while(curPathNode["prevCode"] != nil)
      prevCode = curPathNode["prevCode"]
      prevNode = @map[prevCode]
      routeString = prevNode.name+ ","+routeString
      curPathNode = totalHash[prevCode]
    end
    return routeString
  end
end
