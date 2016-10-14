require_relative "AirGraph"
$FILE_NAME = "temp.json"

class TextInterface
  #list, searchByName, more(1:longest, 2:shortest, 3:average, 4:biggest, 5:samllest, 6:average, 7:continents, 8:hub cities)
  @@default = '0'
  @@list = '1'
  @@search = '2'
  @@statistic = '3'
  @@url = '4'
  @@edit = '5'
  @@jsonGenerate = '6'
  @@mergeFile = '7'
  @@findRoute = '8'
  @@shortestPath = '9'
  @@exit = '10'
  @@longest = 1
  @@shortest = 2
  @@averageDist = 3
  @@biggest = 4
  @@smallest =5
  @@averagePop = 6
  @@continnents = 7
  @@hub = 8
  
  @@addCity = 9
  @@removeCity = 10
  @@addRoute = 11
  @@removeRoute = 12
  @@editInfo = 13
  
=begin
  intialize the air graph and fill flight data in the graph
=end
  def initialize
    @status = @@default;
    @user = "user"
    @graph = AirGraph.new();
    @graph.fillData(setData($FILE_NAME))
    startInterface()
  end
  
=begin
  read file data and return the parsed JSON result
  param: filename
=end
  def setData(fileName)
    file = open(fileName)
    json = file.read
    parsed = JSON.parse(json)
  end
    
=begin
  check if the current status code is exit
  param: input
=end
  def checkExit(input)
    if(input == "exit")
       puts("Have a nice day!")
       exit(0)
    end
  end
 
=begin
  for loop for creating the text interface
=end
  def startInterface
    puts "What name do you want to be referred by?\n"
    @name = $stdin.gets.chomp
    puts "\nHello, "+@name
    puts "================"
    
    while @status != @@exit do
      case @status
        #default interface with three general options
        when @@default
          puts "\nHere are some commands for helping you finding flights: "
          puts "1:list all cities\n2:search city\n3:get general statistics\n4:see all the routes info\n5:edit\n6:Generate Json file\n7:Merge file\n8:find route\n9:shortest path\nEnter index:"
          @status = $stdin.gets.chomp
          checkExit(@status)
        #listing all cities
        when @@list
          puts "\nHere are all cities CS Air flies to:"
          @graph.listCities()
          @status = @@default
        #search for specific city's info
        when @@search
          puts("\nplease type in the city name or 'back' to back to upper level:\n")
          city = $stdin.gets.chomp
          checkExit(city)
          if(city == "back")
            @status = @@default
          else
            foundCity = @graph.getCityInfo(city)
            if(!foundCity)
              puts "Sorry no city named "+city + " found"
            end
          end
        #get a series of statistics about CSAir
        when @@statistic
          puts "\ntype in index for what your are looking for:\n"
          puts "1: longest distance\n2: shortest distance\n3: average distance for all cities\n4: city with largest population\n5: city with smallest population\n6: average population for all cities\n7: continents we fly to\n8: hub cities\nEnter index:"
          choice = $stdin.gets.chomp
          while choice != "back" do
            checkExit(choice)
            choice = choice.to_i
            if(choice < 1 || choice > 8)
              puts("\nplease choose number between 1 and 8\n")
            else
              if(choice == @@biggest)
                @graph.findCityByPopluation(true)
              elsif(choice == @@smallest)
                @graph.findCityByPopluation(false)
              elsif(choice == @@averagePop)
                @graph.findAvgByPopulation()
              elsif(choice == @@averageDist)
                @graph.findAvgByDistance()
              elsif(choice == @@longest)
                @graph.findCityByDistance(true)
              elsif(choice == @@shortest)
                @graph.findCityByDistance(false)
              elsif(choice == @@continnents)
                @graph.listContinents()
              elsif(choice == @@hub)
                @graph.listHubs()
              end
            end
            choice = $stdin.gets.chomp
          end
          @status = @@default
        #go to the website
        when @@url
          @graph.getUrl()
          @status = @@default
        when @@edit
            puts "\ntype in index for what your are looking for:\n"
            puts "1: add a city\n2: remove a city\n3: add a route\n4: remove a route\n5: edit a city\nEnter index:"
            choice = $stdin.gets.chomp
            while choice != "back" do
              checkExit(choice)
              choice = (choice.to_i) + 8
              case choice
                when @@addCity
                  puts "city code(all whitespace will be removed): "
                  code = (@graph.purifyInput("code",$stdin.gets.chomp))["value"]
                  puts "name:"
                  name = (@graph.purifyInput("name",$stdin.gets.chomp))["value"]
                  puts "country:"
                  country = $stdin.gets.chomp
                  continent = nil
                  while continent == nil
                    puts "continent:(please choose continent from the lis: Africa, Antarctica, Asia, Australia, Europe, North America,South America)"
                    temp = @graph.purifyInput("continent",$stdin.gets.chomp)
                    continent = (temp == nil)? temp : temp["value"]
                  end
                  coordinates = nil
                  while(coordinates == nil)
                    puts "\nchoose N or S:"
                    ns = $stdin.gets.chomp
                    puts "\nvalue: "
                    nsVal = $stdin.gets.chomp.to_i
                    puts "\nchoose E or W:"
                    ew = $stdin.gets.chomp
                    puts "\nvalue: "
                    ewVal = $stdin.gets.chomp.to_i
                    temp = @graph.purifyInput("coordinates", {ns => nsVal, ew => ewVal})
                    if(temp == nil)
                      puts "\nSorry, your input is not correct, please try again\n"
                    else
                      coordinates = {ns => nsVal, ew => ewVal}
                    end
                  end
                  population = nil
                  while(population == nil)
                    puts "\npopulation:"
                    temp = @graph.purifyInput("population",$stdin.gets.chomp)
                    if(temp == nil )
                      puts "\nSorry, please type a positive number"
                    else
                      population = temp["value"]
                    end
                  end
                  puts "\nregion:"
                  region = $stdin.gets.chomp
                  timezone = nil
                  while(timezone == nil)
                    puts "\ntimezone:"
                    temp = @graph.purifyInput("timezone",$stdin.gets.chomp)
                    if(temp != nil)
                      timezone = temp["value"]
                    else
                      puts "illegal timezone"
                    end
                  end
                  
                  if(@graph.addCity(code, name, country, continent, timezone, coordinates, population, region) == false)
                    puts "\nsorry, the city already exists"
                  else
                    puts "\nSuccessifully added city " + name + " \n"
                  end
                when @@removeCity
                  puts "\nremove city name: "
                  city = $stdin.gets.chomp
                  if(@graph.removeCity(city) == false)
                    puts "\nFailed to remove city\n"
                  else
                    puts "\nSuccessifully removed city " +city + " \n"
                  end
                when @@addRoute 
                 puts "\nenter depature city: "
                 city1 = $stdin.gets.chomp
                 puts "\nenter desination:"
                 city2 = $stdin.gets.chomp
                 puts "\ndistance:"
                 dis = $stdin.gets.chomp
                 if(@graph.addRoute(city1, city2, dis) == false)
                   puts "\nfailed to add route\n"
                 else
                   puts "\nsuccessifully add route between "+city1 + " and " + city2 + "\n"
                 end
                when @@removeRoute 
                  puts "\nenter depature city: "
                  city1 = $stdin.gets.chomp
                  puts "\nenter desination:"
                  city2 = $stdin.gets.chomp
                  if(@graph.removeRoute(city1, city2) == false)
                    puts "\nfailed to remove route\n"
                  else
                    puts "\nSuccessifull remove route between " + city1 +" and " + city2 +"\n"
                  end
                when @@editInfo
                  puts "\nenter city name:"
                  city = $stdin.gets.chomp
                  if(@graph.getCityInfo(city) == false)
                    puts "sorry the city doesn't exist\n"
                  end
                  keys = ['name', 'country', 'continent', 'timezone', 'coordinates', 'population', 'region']
                  key = nil
                  while(key == nil)
                    puts "\nplease type the index for what you want to edit\n"
                    puts " 1: name\n 2: country\n 3: continent\n 4: timezone\n 5:coordinates\n 6:population\n 7:region\n"
                    choice = ($stdin.gets.chomp.to_i)-1
                    puts choice
                    if(choice >= 0 && choice < keys.length)
                      key = keys[choice]
                      puts key
                    end
                  end
                  
                  value = -1
                  if(choice == 4)
                    puts "\nchoose N or S:"
                    ns = $stdin.gets.chomp
                    puts "\nvalue: "
                    nsVal = $stdin.gets.chomp
                    puts "\nchoose E or W:"
                    ew = $stdin.gets.chomp
                    puts "\nvalue: "
                    ewVal = $stdin.gets.chomp
                    value = {ns=>nsVal, ew=>ewVal}
                  else
                    puts "\nvalue: "
                    value = $stdin.gets.chomp
                  end
                          
                  if(@graph.editCity(key,value,city) == true)
                    puts("\nsuccessifully edit the city:\n")
                    if(choice == 1)
                      @graph.getCityInfo(value)
                    else
                      @graph.getCityInfo(city)
                    end
                    
                  else
                    puts("\nfailed to change the value")
                  end
                else
                  puts "\nPlease enter legal number\n"
                end
              #reinitalize
              puts "\ntype in index for what your are looking for:\n"
              puts "1: add a city\n2: remove a city\n3: add a route\n4: remove a route\n5: edit a city\nEnter index:"
              choice = $stdin.gets.chomp
            end
            @status = @@default
          when @@jsonGenerate
            puts "Please enter file name(without .json):\n"
            fileName = $stdin.gets.chomp+".json"
            jsonObj = @graph.createJSON()
            File.open(fileName, 'w') {|f| f.truncate(0) }
            File.open(fileName, "w") do |f|
               f.write(jsonObj.to_json)
            end
            puts "finish write to the file: "+fileName
            @status = @@default
          when @@mergeFile
            puts "Please enter file name(without .json):\n"
            fileName = $stdin.gets.chomp+".json"
            parsed = setData(fileName)
            @graph.fillData(parsed)
            puts "finish extending map\n"
            @status = @@default 
          when @@findRoute
            puts "Please enter a series of cities, seperate with comma:"
            cities = $stdin.gets.chomp
            info = @graph.getRouteInfo(cities)
            if(info == nil)
              puts "Sorry, no such route exists"
            else
              puts "Total distance: "+info['dist'].to_s+" km\n"
              puts "Total cost: "+info['cost'].to_s+" dollars\n"
              puts "Total time: "+info['time'].to_s+" hours\n"
            end
            @status = @@default
          when @@shortestPath
            puts "\nEnter depature city:"
            city1 = $stdin.gets.chomp
            puts "\nEnter destination:"
            city2 = $stdin.gets.chomp
            route = @graph.findShortestPath(city1, city2)
            if(route == nil)
              puts "\nSorry, there is no route between these two cities"
            else
              info = @graph.getRouteInfo(route)
              puts "\nShortest route: " + route + "\n"
              puts "Total distance: "+info['dist'].to_s+" km\n"
              puts "Total cost: "+info['cost'].to_s+" dollars\n"
              puts "Total time: "+info['time'].to_s+" hours\n"
            end
            @status = @@default
          else
            break
          end
      end    
  end
end

#initiate the interface when launch the program
interface = TextInterface.new()