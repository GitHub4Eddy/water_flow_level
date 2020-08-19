-- QuickApp Water Level 

-- This QuickApp gets the actual water levels from rivers in France
-- The latest water level of your selected hydro station is updated in the value of this QuickApp
-- See for more information: https://www.vigicrues.gouv.fr
-- Service d'information sur le risque de crues des principaux cours d'eau en France

-- Version 0.6 (16th August 2020)
-- ...

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


-- No modifications are needed below this line


function QuickApp:onInit()
    __TAG = "WATER_LEVEL_"..plugin.mainDeviceId
    self:debug("OnInit") 
    self.http = net.HTTPClient({timeout=3000})
     
    Address = self:getVariable("Address")
    Path = self:getVariable("Path")
    StationHydro = self:getVariable("StationHydro")
    Interval = tonumber(self:getVariable("Interval")) 

    -- Check existence of the mandatory variables, if not, create them with default values
    if Address == "" or Address == nil then 
      Address = "https://www.vigicrues.gouv.fr/services/observations.json/index.php?CdStationHydro=" -- Default Address 
      self:setVariable("Address",Address)
      self:trace("Added QuickApp variable Addres")
    end
    if Path == "" or Path == nil then 
      Path = "&GrdSerie=H&FormatSortie=simple" -- Default path
      self:setVariable("Path",Path)
      self:trace("Added QuickApp variable Path")
    end
    if StationHydro =="" or StationHydro == nil then
      StationHydro = "F700000103" -- Default StationHydro is F700000103
      self:setVariable("StationHydro",StationHydro)
      self:trace("Added QuickApp variable StationHydro")
    end
    if Interval == "" or Interval == nil then
      Interval = "3600" -- Default interval is 3600
      self:setVariable("Interval",Interval)
      self:trace("Added QuickApp variable Interval")   
      Interval = tonumber(Interval)
    end

    self:loop("")
end

function QuickApp:loop(text)

    local url = Address ..StationHydro ..Path
    local Act_WaterLevel = 0
    local Act_DateTime = 0

    self.http:request(url, {
      options={
        headers = {Accept = "application/json"}, method = 'GET'}, success = function(response)
        --self:debug("response status:", response.status) 
        --self:debug("headers:", response.headers["Content-Type"]) 
        apiResult = response.data

        --self:debug("Full apiResult: ",apiResult)

        jsonTable = json.decode(apiResult) -- JSON decode from api to lua-table

        -- Get the values
        local VersionFlux = jsonTable.VersionFlux 
        local LbStationHydro = jsonTable.Serie.LbStationHydro 
        local Link = jsonTable.Serie.Link
        local GrdSerie = jsonTable.Serie.GrdSerie

        --self:debug("VersionFlux: ", VersionFlux)
        --self:debug("LbStationHydro: ", LbStationHydro)
        --self:debug("Link: ", Link)
        --self:debug("GrdSerie: ", GrdSerie) 

 
        for i in pairs(jsonTable.Serie.ObssHydro) do 
          DateTime = os.date("%d-%m-%Y %X", string.sub(jsonTable.Serie.ObssHydro[i][1],1,10))
          WaterLevel = jsonTable.Serie.ObssHydro[i][2]
          if jsonTable.Serie.ObssHydro[i][1] > Act_DateTime then
            Act_DateTime = jsonTable.Serie.ObssHydro[i][1]
            Act_WaterLevel = WaterLevel
          end
        end
        Act_DateTime = os.date("%d-%m-%Y %X", string.sub(Act_DateTime,1,10))

        -- Notification 
        self:debug("On " ..Act_DateTime .." the actual water level is " ..Act_WaterLevel .." at " ..LbStationHydro)

        -- Update properties
        self:updateProperty("value", tonumber(Act_WaterLevel))
        self:updateProperty("unit", "m")
        self:updateProperty("log", Act_DateTime)

        -- Update View
        self:updateView("label1", "text", "Station Hydro: " ..LbStationHydro) 
        self:updateView("label2", "text", "Date time: " ..Act_DateTime)
        self:updateView("label3", "text", "Actual WaterLevel: " ..Act_WaterLevel .." m")

        --self:debug("--------------------- END --------------------") 

      end,
      error = function(error)
      self:error('error: ' .. json.encode(error))
      self:updateProperty("log", "error: " ..json.encode(error))
    end
    }) 

    fibaro.setTimeout(Interval*1000, function() -- Checks every n seconds for new data
    self:loop(text)
  end)
end 
