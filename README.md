# water_flow_level

QuickApp Water Flow Level 

This QuickApp gets the actual water levels or flow from rivers in France
The latest water level or flow of your selected hydro station is updated in the value of this QuickApp
You can choose between Water Level or Water Flow. If you want both, simply install the QuickApp twice
See for more information: https://www.vigicrues.gouv.fr
Service d'information sur le risque de crues des principaux cours d'eau en France


Version 1.0 (25th April 2021)
- Added Water Flow next to Water Level, mode = level or flow (Choose for waterlevel or waterflow, default = level)
- Added debugLevel (Number (1=some, 2=few, 3=almost all, 4=all) (default = 1))
- Re-structured the code

Version 0.5 (16th August 2020)
- Error message instead of debug message in case of error
- Adjusted the date/time in the label and debug message. If the json file was in a different order, a wrong date/time could show. 
- Changed method of adding QuickApp variables, so they can be edited

Version 0.4 (7th August 2020)
- Changed debug message actual level with location
- Added QuickApp variables

Version 0.3 (3rd August 2020)
- Put the latest WaterLevel value in QuickApp value
- Put the latest DateTime value in the QuickApp log
- Added labels with the json data
- Added debug notification

Version 0.2 (3nd August 2020)
- Date time value converted to readable time
- Added the latest date, time and waterlevel values


QuickApp variables (mandatory): 
- stationHydro = Status from where you want your data from
- mode = level or flow (Choose for waterlevel or waterflow, default = level)
- interval = Number in seconds to request the data
- debugLevel = Number (1=some, 2=few, 3=all) (default = 1)
