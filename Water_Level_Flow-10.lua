-- QuickApp Water Flow Level 

-- This QuickApp gets the actual water levels or flow from rivers in France
-- The latest water level or flow of your selected hydro station is updated in the value of this QuickApp
-- You can choose between Water Level or Water Flow. If you want both, simply install the QuickApp twice
-- See for more information: https://www.vigicrues.gouv.fr
-- Service d'information sur le risque de crues des principaux cours d'eau en France


-- Version 1.0 (25th April 2021)
-- Added Water Flow next to Water Level, mode = level or flow (Choose for waterlevel or waterflow, default = level)
-- Added debugLevel (Number (1=some, 2=few, 3=almost all, 4=all) (default = 1))
-- Re-structured the code

-- Version 0.5 (16th August 2020)
-- Error message instead of debug message in case of error
-- Adjusted the date/time in the label and debug message. If the json file was in a different order, a wrong date/time could show. 
-- Changed method of adding QuickApp variables, so they can be edited

-- Version 0.4 (7th August 2020)
-- Changed debug message actual level with location
-- Added QuickApp variables

-- Version 0.3 (3rd August 2020)
-- Put the latest WaterLevel value in QuickApp value
-- Put the latest DateTime value in the QuickApp log
-- Added labels with the json data
-- Added debug notification

-- Version 0.2 (3nd August 2020)
-- Date time value converted to readable time
-- Added the latest date, time and waterlevel values


-- QuickApp variables (mandatory): 
-- stationHydro = Status from where you want your data from
-- mode = level or flow (Choose for waterlevel or waterflow, default = level)
-- interval = Number in seconds to request the data
-- debugLevel = Number (1=some, 2=few, 3=all) (default = 1)


-- Example json output Water Level:
-- {"VersionFlux":"Beta 0.4b","Serie":{"CdStationHydro":"F700000103","LbStationHydro":"Paris [Austerlitz - Station d\u00e9bitm\u00e9trique ultrasons]","Link":"https:\/\/www.vigicrues.gouv.fr\/services\/station.json?CdStationHydro=F700000103","GrdSerie":"H","ObssHydro":[[1615849200000,1.27],[1615852800000,1.28],[1615856400000,1.29],[1615860000000,1.3],[1615863600000,1.29],[1615867200000,1.3],[1615870800000,1.29],[1615874400000,1.3],[1615878000000,1.29],[1615881600000,1.32],[1615885200000,1.32],[1615888800000,1.33],[1615892400000,1.32],[1615896000000,1.32],[1615899600000,1.3],[1615903200000,1.29],[1615906800000,1.26],[1615910400000,1.23],[1615914000000,1.19],[1615917600000,1.19],[1615921200
-- truncated

-- Example json outputWater Flow:
-- {"VersionFlux":"Beta 0.4b","Serie":{"CdStationHydro":"F700000103","LbStationHydro":"Paris [Austerlitz - Station d\u00e9bitm\u00e9trique ultrasons]","Link":"https:\/\/www.vigicrues.gouv.fr\/services\/station.json?CdStationHydro=F700000103","GrdSerie":"Q","ObssHydro":[[1615849200000,368.8],[1615852800000,371.7],[1615856400000,367.4],[1615860000000,367],[1615863600000,364.8],[1615867200000,366],[1615870800000,371.2],[1615874400000,370.7],[1615878000000,367.4],[1615881600000,375.2],[1615885200000,366.9],[1615888800000,378.2],[1615892400000,356.6],[1615896000000,380],[1615899600000,384],[1615903200000,371.3],[1615906800000,363.5],[1615910400000,344.7],[1615914000000,340.4],[1615917600000,34
-- truncated


-- No modifications are needed below this line


function QuickApp:logging(level,text) -- Logging function for debug
  if tonumber(debugLevel) >= tonumber(level) then 
      self:debug(text)
  end
end


function QuickApp:updateProperties() -- Update the properties
  self:logging(3,"QuickApp:updateProperties")
  self:updateProperty("value", tonumber(data.Act_WaterLevelFlow))
  if mode == "level" then 
    self:updateProperty("unit", "m")
  else
    self:updateProperty("unit", "m³/s")
  end
  self:updateProperty("log", data.Act_DateTime)
end


function QuickApp:updateLabels() -- Update the labels
  self:logging(3,"QuickApp:updateLabels")
  local labelText = ""
  labelText = labelText .."Station Hydro: " ..data.LbStationHydro  .."\n\n"
  labelText = labelText .."Date time: " ..data.Act_DateTime .."\n\n" 
  if mode == "level" then
    labelText = labelText  .."WaterLevel: " ..data.Act_WaterLevelFlow .." m" .."\n"
  else
    labelText = labelText  .."WaterFlow: " ..data.Act_WaterLevelFlow.." m³/s" .."\n"
  end
  self:updateView("label1", "text", labelText)
  self:logging(2,labelText)
end


function QuickApp:getValues() -- Get the values
  self:logging(3,"QuickApp:getValues")
  data.VersionFlux = jsonTable.VersionFlux 
  data.LbStationHydro = jsonTable.Serie.LbStationHydro 
  data.Link = jsonTable.Serie.Link
  data.GrdSerie = jsonTable.Serie.GrdSerie
  
  self:logging(2,"VersionFlux: " ..data.VersionFlux)
  self:logging(2,"LbStationHydro: " ..data.LbStationHydro)
  self:logging(2,"Link: " ..data.Link)
  self:logging(2,"GrdSerie: " ..data.GrdSerie) 
  
  local i = 1
  for i in pairs(jsonTable.Serie.ObssHydro) do 
    --data.Act_DateTime = os.date("%d-%m-%Y %X", string.sub(jsonTable.Serie.ObssHydro[i][1],1,10))
    data.Act_DateTime = jsonTable.Serie.ObssHydro[1][1]
    data.WaterLevelFlow = jsonTable.Serie.ObssHydro[i][2]
    if jsonTable.Serie.ObssHydro[i][1] > data.Act_DateTime then
      data.Act_DateTime = jsonTable.Serie.ObssHydro[i][1]
      data.Act_WaterLevelFlow = data.WaterLevelFlow
    end
  end
  data.Act_DateTime = string.sub(data.Act_DateTime,1,10)
  data.Act_DateTime = os.date("%d-%m-%Y %X", data.Act_DateTime)
  self:logging(2,"Act_DateTime: " ..data.Act_DateTime) 
end


function QuickApp:getData() -- Get data
  self:logging(3,"QuickApp:getData")
  local url = address ..stationHydro ..path
  self:logging(3,"url: " ..url)

  self.http:request(url, {
    options={
      headers = {Accept = "application/json"}, method = 'GET'}, success = function(response)
      self:logging(3,"response status:" ..response.status) 
      self:logging(3,"headers:" ..response.headers["Content-Type"]) 
      apiResult = response.data

      self:logging(4,"Full apiResult: " ..apiResult)

      jsonTable = json.decode(apiResult) -- JSON decode from api to lua-table

      self:getValues() -- Get the values
      self:updateLabels() -- Update the labels
      self:updateProperties() -- Update the properties

    end,
    error = function(error)
    self:error('error: ' .. json.encode(error))
    self:updateProperty("log", "error: " ..json.encode(error))
  end

  }) 

  self:logging(3,"SetTimeout " ..interval .." seconds")
  fibaro.setTimeout(interval*1000, function() -- Checks every n seconds for new data
    self:getData()
  end)
end 


function QuickApp:createVariables() -- Get all Quickapp Variables or create them
  address = "https://www.vigicrues.gouv.fr/services/observations.json/index.php?CdStationHydro=" -- Default Address 
  local pathLevel = "&GrdSerie=H&FormatSortie=simple" -- Default path Water Level
  local pathFlow = "&GrdSerie=Q&FormatSortie=simple" -- Default path Water Flow
  if mode == "level" then -- Set initial value for Path
    path = pathLevel 
  else
    path = pathFlow 
  end
  data = {}
  data.WaterLevelFlow = 0
  data.Act_WaterLevelFlow = 0
  data.Act_DateTime = 0
  data.VersionFlux = ""
  data.LbStationHydro = ""
  data.Link = ""
  data.GrdSerie = ""
end


function QuickApp:getQuickappVariables() -- Get all Quickapp Variables or create them
  stationHydro = self:getVariable("stationHydro")
  mode = string.lower(self:getVariable("mode"))
  interval = tonumber(self:getVariable("interval")) 
  debugLevel = tonumber(self:getVariable("debugLevel"))

  -- Check existence of the mandatory variables, if not, create them with default values
  if stationHydro =="" or stationHydro == nil then
    stationHydro = "F700000103" -- Default stationHydro is F700000103
    self:setVariable("stationHydro",stationHydro)
    self:trace("Added QuickApp variable stationHydro")
  end
  if mode =="" or mode == nil then
    mode = "level" -- Default Mode is level
    self:setVariable("mode",mode)
    self:trace("Added QuickApp variable mode")
  end
  if interval == "" or interval == nil then
    interval = "3600" -- Default interval is 3600
    self:setVariable("interval",interval)
    self:trace("Added QuickApp variable interval")   
    interval = tonumber(interval)
  end
  if debugLevel == "" or debugLevel == nil then
    debugLevel = "1" -- Default value for debugLevel
    self:setVariable("debugLevel",debugLevel)
    self:trace("Added QuickApp variable debugLevel")
    debugLevel = tonumber(debugLevel)
  end
end


function QuickApp:onInit()
  __TAG = fibaro.getName(plugin.mainDeviceId) .." ID:" ..plugin.mainDeviceId
  self:debug("OnInit") 
  self.http = net.HTTPClient({timeout=3000})
    
  self:getQuickappVariables() -- Get Quickapp Variables or create them
  self:createVariables() -- Create Variables
  self:getData() -- Go to getData
end

-- EOF
