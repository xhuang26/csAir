class CityNode
  attr_accessor(:name, :code, :country, :continent, :timezone, :coordinates, :population, :region, :destinations)

=begin
  initialize CityNode, eachnode has code, name, country, continent, timezone, population, region, and destination(hash with code as key and distance as value)
=end
  def initialize(code, name, country, continent, timezone, coordinates, population, region)
    @code = code
    @name = name
    @country = country
    @continent = continent
    @timezone = timezone
    if(coordinates != nil && (coordinates.is_a? String)==false)
      @coordinates = parseCoords(coordinates)
    else
      @coordinates = coordinates
    end
    @population = population
    @region = region
    @destinations = Hash.new
  end
  
=begin
  param: code, dist
  add a new key value pair in distance hash
=end
  def addDest(code, dist)
    notExist = true
    if(@destinations[code] == nil)
      notExist = false
    end
    @destinations[code] = dist
  end
  
=begin
  param: code
  find if the city with the passed-in code is a destination to the current CityNode, if it's not return false
=end
  def findDes(code)
    @destinations[code] != nil
  end
  
=begin
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
=end
  def setValue(key, value, node)
    if(key == 'code')
      node.code = value;
    elsif(key == 'name')
      node.name = value;
    elsif(key == 'coordinates')
      node.coordinates = value;
    elsif(key == 'country')
      node.country = value;
    elsif(key == 'continent')
      node.continent = value;
    elsif(key == 'region')
      node.region = value;
    elsif(key == 'timezone')
      node.timezone = value;
    elsif(key == 'population')
      node.population = value;
    end
  end
  
end