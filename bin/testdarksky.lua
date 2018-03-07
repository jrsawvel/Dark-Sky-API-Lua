#!/usr/local/bin/lua


-- testdarksky.lua
-- March 2018
-- jr@sawv.org



package.path = package.path .. ';../lib/?.lua'



local DarkSky = require "darksky"
local dsutils = require "dsutils"



local api_key   = "<api key>"
local latitude  = "41.665556"
local longitude = "-83.575278"

local ds = DarkSky(api_key, latitude, longitude)

-- print(ds:apiurl())

-- access old data
-- ds:apiurl(ds:apiurl() .. ",2012-07-11T12:00:00-0400")

-- change the url to point to test data.
-- currently the code requires the data to be stored at https, like Dark Sky uses.
-- ds:apiurl("https://elsewhere/darksky05mar2018.json")

-- can also retrieve old data by doing:
--    ds:fetch_data("2018-03-05T:17:24:39-0000")
local rc, wx = ds:fetch_data()

if rc == false then
    print(wx)
    error("unable to retrieve Dark Sky JSON data.")
end

-- dump Lua table contents, show arrays, hashes, and arrays of hashes.
-- dsutils.table_print(wx)

--[[
Lua table representation for current conditions.

[currently] => table
    (
       [humidity] => 0.49
       [time] => 1520269162.0
       [visibility] => 4.39
       [windGust] => 9.47
       [temperature] => 34.16
       [windSpeed] => 7.2
       [summary] => Clear
       [apparentTemperature] => 27.96
       [cloudCover] => 0.2
       [ozone] => 340.08
       [uvIndex] => 3.0
       [icon] => clear-day
       [precipProbability] => 0.0
       [nearestStormBearing] => 203.0
       [pressure] => 1025.9
       [windBearing] => 80.0
       [precipIntensity] => 0.0
       [dewPoint] => 17.19
       [nearestStormDistance] => 84.0
    )

]]

-- current conditions, showing raw Dark Sky data.
-- for k,v in pairs(wx.currently) do
--     print(k, v)
-- end

-- get the list of current weather conditions
local currently = wx.currently

local wind_direction, wind_direction_fullname, wind_gust
local wind_speed     = dsutils.round(currently.windSpeed)
if wind_speed == 0 or currently.windBearing == nil then
    wind_direction = "Calm"
    wind_direction_fullname = "Calm"
else 
    wind_direction =  dsutils.degrees_to_cardinal(currently.windBearing)
    wind_direction_fullname =  dsutils.degrees_to_cardinal_fullname(currently.windBearing)
    wind_gust = dsutils.round(currently.windGust)
end


print("Current Weather Conditions")


print(" date and time = " .. dsutils.format_date_iso(currently.time))
print(" timezone and offset = " .. wx.timezone .. " : " .. wx.offset)
print(" longitude and latitude = " .. wx.longitude .. " " .. wx.latitude)
print(" summary = " .. currently.summary)
print(" icon = " .. currently.icon)
print(" air temp = " .. dsutils.round(currently.temperature) .. " F")
print(" dew point = " .. dsutils.round(currently.dewPoint) .. " F")
print(" wind direction = " .. wind_direction)
print(" wind direction full name = " .. wind_direction_fullname)
print(" wind speed = " .. wind_speed .. " mph")
print(" wind gust = " .. wind_gust .. " mph")
print(" temp feels like = " .. dsutils.round(currently.apparentTemperature) .. " F")
print(" pressure = " .. currently.pressure .. " mb")
print(" pressure = " .. dsutils.millibars_to_inches(currently.pressure) .. " in")
print(" humidity = " .. dsutils.round(currently.humidity * 100) .. "%")
print(" ozone = " .. currently.ozone .. " Dobson units")
print(" uv index = " .. currently.uvIndex)

local uvindex_rating, uvindex_color = dsutils.get_uvindex_info(currently.uvIndex)
print(" uv index rating = " .. uvindex_rating)
print(" uv index color code = " .. uvindex_color)

print(" precip prob = " .. dsutils.round(currently.precipProbability * 100) .. "%")
print(" cloud cover = " .. dsutils.round(currently.cloudCover * 100) .. "%")
print(" cloud cover desc = " .. dsutils.cloud_cover_description(currently.cloudCover))
print(" precip itensity = " .. currently.precipIntensity)

local precip_desc, precip_color = dsutils.calc_precip_intensity_and_color(currently.precipIntensity)
print(" precip intensity desc = " .. precip_desc)
print(" precip intensity color = " .. precip_color)

if currently.precipIntensity > 0.0 then
    print(" precip type = " .. currently.precipType)
end

print(" visibility = " .. currently.visibility .. " miles")
if currently.nearestStormDistance < 1.0 then
    print( " precip is occurring over or near this location.")
else 
    print(" nearsest precip bearing = " .. dsutils.degrees_to_cardinal_fullname(currently.nearestStormBearing)) 
    print(" nearest precip distance = " .. dsutils.round(currently.nearestStormDistance) .. " miles")
end

print("\n\nSummaries for the following time periods.")
print("  Now: " .. currently.summary)
print("  Next 60 minutes: " .. wx.minutely.summary)
print("  Next 48 hours: " .. wx.hourly.summary)
print("  Next 7 days: " .. wx.daily.summary)


print("\n\nForecast for the upcoming week.")
local daily = wx.daily.data

for i=1, #daily do
    local date = os.date("%a, %b %d", daily[i].time)
    local str = "\n  " .. date .. ": " 
    str = str .. daily[i].summary 
    str = str .. " Hi " .. dsutils.round(daily[i].temperatureMax) 
    str = str .. ", Lo " .. dsutils.round(daily[i].temperatureMin) .. "."

    local wd, ws, wg
    ws = dsutils.round(daily[i].windSpeed)
    if ws == 0 or daily[i].windBearing == nil then
        str = str .. " Calm winds."
    else 
        wd = dsutils.degrees_to_cardinal_fullname(daily[i].windBearing)
        wg = dsutils.round(daily[i].windGust)
        str = str .. " " .. wd .. " winds at " .. ws .. " mph with wind gusts up to " .. wg .. " mph."
    end

    str = str .. " Chance of precipation is " .. dsutils.round(daily[i].precipProbability * 100) .. "%."
    if daily[i].precipIntensity > 0.0 then
--        str = str .. " mostly  " .. daily[i].precipType .. "."
        if  daily[i].precipType == "snow" then
            str = str .. " Snow accumulating " .. daily[i].precipAccumulation .. " inches."
        end
    end
    print(str)
end

