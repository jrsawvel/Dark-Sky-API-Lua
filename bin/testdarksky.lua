#!/usr/local/bin/lua


-- testdarksky.lua
-- March 2018
-- jr@sawv.org



package.path = package.path .. ';../lib/?.lua'



local DarkSky = require "darksky"
local dsutils = require "dsutils"



local api_key   = "<api-key>"
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
local wind_speed = dsutils.round(currently.windSpeed)
if wind_speed == 0 or currently.windBearing == nil then
    wind_direction = "Calm"
    wind_direction_fullname = "Calm"
else 
    wind_direction =  dsutils.degrees_to_cardinal(currently.windBearing)
    wind_direction_fullname =  dsutils.degrees_to_cardinal_fullname(currently.windBearing)
    wind_gust = dsutils.round(currently.windGust)
end

print("Current Weather Conditions")
print("              date and time = " .. dsutils.format_date_iso(currently.time))
print("                    summary = " .. currently.summary)
print("                       icon = " .. currently.icon)
print("                   air temp = " .. dsutils.round(currently.temperature) .. " F")
print("                  dew point = " .. dsutils.round(currently.dewPoint) .. " F")
print("             wind direction = " .. wind_direction)
print("   wind direction full name = " .. wind_direction_fullname)
print("                 wind speed = " .. wind_speed .. " mph")
print("                  wind gust = " .. wind_gust .. " mph")
print("            temp feels like = " .. dsutils.round(currently.apparentTemperature) .. " F")
print("                   pressure = " .. currently.pressure .. " mb")
print("                   pressure = " .. dsutils.millibars_to_inches(currently.pressure) .. " in")
print("                   humidity = " .. dsutils.round(currently.humidity * 100) .. "%")
print("                      ozone = " .. currently.ozone .. " Dobson units")
print("                   uv index = " .. currently.uvIndex)

local uvindex_rating, uvindex_color = dsutils.get_uvindex_info(currently.uvIndex)
print("            uv index rating = " .. uvindex_rating)
print("        uv index color code = " .. uvindex_color)

print("                precip prob = " .. dsutils.round(currently.precipProbability * 100) .. "%")
print("                cloud cover = " .. dsutils.round(currently.cloudCover * 100) .. "%")
print("           cloud cover desc = " .. dsutils.cloud_cover_description(currently.cloudCover))
print("            precip itensity = " .. currently.precipIntensity)

local precip_desc, precip_color = dsutils.calc_precip_intensity_and_color(currently.precipIntensity)
print("      precip intensity desc = " .. precip_desc)
print("     precip intensity color = " .. precip_color)

if currently.precipIntensity > 0.0 then
    print("                precip type = " .. currently.precipType)
end

print("                 visibility = " .. currently.visibility .. " miles")
if currently.nearestStormDistance < 1.0 then
    print( " precip is occurring over or near this location.")
else 
    print("    nearsest precip bearing = " .. dsutils.degrees_to_cardinal_fullname(currently.nearestStormBearing)) 
    print("    nearest precip distance = " .. dsutils.round(currently.nearestStormDistance) .. " miles")
end




print("\n\nMinute by Minute Forecast - Next Hour")
local minutely = wx.minutely.data
for i=1, #minutely do
    local m = minutely[i]
    local m_str = dsutils.format_date_iso(m.time) .. " "
    if m.precipIntensity > 0.0 then
        m_str = m_str .. ": " .. dsutils.round(m.precipProbability * 100) .. "% precip chance "
        local x,y = dsutils.calc_precip_intensity_and_color(m.precipIntensity)
        m_str = m_str .. ": " .. x .. " "
        m_str = m_str .. ": " .. m.precipType
    else
        m_str = m_str .. ": No Precip"
    end
    print(m_str)
end



print("\n\nHourly Forecast - Next 48 Hours")
local hourly = wx.hourly.data
for i=1, #hourly do
    local h = hourly[i]
    print("    date = " .. dsutils.format_date_iso(h.time))
    print("    local time = " .. os.date("%I:%M %p, %a, %b %d, %Y ", h.time + (wx.offset * 3600)))
    print("    icon = " .. h.icon)
    print("    temperature = " .. dsutils.round(h.temperature))
    print("    feels like temp = " .. dsutils.round(h.apparentTemperature))

    local wd, ws, wg -- wind direction, wind speed, and wind gust
    ws = dsutils.round(h.windSpeed)
    if ws == 0 or h.windBearing == nil then
        print("    wind = calm")
    else 
        wd  = dsutils.degrees_to_cardinal(h.windBearing)
        wg  = dsutils.round(h.windGust)
        print("    wind = " .. wd .. " " .. ws .. " mph, gust: " .. wg .. " mph")
    end

    if h.precipIntensity > 0.0 then
        print("    precip chance = " .. dsutils.round(h.precipProbability * 100) .. "%") 
        local x,y = dsutils.calc_precip_intensity_and_color(h.precipIntensity)
        print("    precip intensity = " .. x)
        print("    preip type = " .. h.precipType)
    else
        print("    precip chance = 0%")
    end
    print("    cloud cover amount = " .. dsutils.round(h.cloudCover * 100) .. "%")
    print("    humidity = " .. dsutils.round(h.humidity * 100) .. "%")
    local uvi_rating, uvi_color = dsutils.get_uvindex_info(h.uvIndex)
    print("    uv index = " .. uvi_rating .. "\n")
end




print("\nDaily Forecast - Next 7 Days")

local daily = wx.daily.data

for i=1, #daily do
    local d = daily[i]
    local date = os.date("%a, %b %d, %Y", d.time)

    local wd, wdf, ws, wg, wgt -- wind direction, wind direction full name, wind speed, wind gust, and wind gust time
    ws = dsutils.round(d.windSpeed)
    if ws == 0 or d.windBearing == nil then
        wd  = "calm" 
        wdf = "calm"
        wg = "na"
        wgt = "na"
    else 
        wd  = dsutils.degrees_to_cardinal(d.windBearing)
        wdf = dsutils.degrees_to_cardinal_fullname(d.windBearing)
        wg  = dsutils.round(d.windGust)
        wgt = dsutils.format_date_iso(d.windGustTime)
    end

    local snow_accumulation = 0.0
    local precip_type = "na"
    local precip_intensity_max_value = 0.0
    local precip_intensity_max_desc = "na"
    local precip_intensity_max_time = "na"

    if d.precipIntensity > 0.0 then
        precip_intensity_max_value = d.precipIntensityMax
        precip_intensity_max_desc = dsutils.calc_precip_intensity_and_color(d.precipIntensityMax)
        precip_intensity_max_time = dsutils.format_date_iso(d.precipIntensityMaxTime)

        if  d.precipType == "snow" then
            snow_accumulation = d.precipAccumulation 
        end
        
        precip_type = d.precipType
    end

    local uvi_rating, uvi_color = dsutils.get_uvindex_info(d.uvIndex)

    print("                       date = " .. date)
    print("              date and time = " .. dsutils.format_date_iso(d.time))
    print("                    summary = " .. d.summary) 
    print("                       icon = " .. d.icon)
    print("                    sunrise = " .. dsutils.format_date_iso(d.sunriseTime))
    print("                     sunset = " .. dsutils.format_date_iso(d.sunsetTime))
    print("         cloud cover amount = " .. dsutils.round(d.cloudCover * 100) .. "%")
    print("           cloud cover desc = " .. dsutils.cloud_cover_description(d.cloudCover))
    print("                precip type = " .. precip_type)
    print("         precip probability = " .. dsutils.round(d.precipProbability * 100) .. "%")
    print("          snow accumulation = " .. snow_accumulation .. " in.")
    print("     precip intensity value = " .. d.precipIntensity)
    print("      precip intensity desc = " .. dsutils.calc_precip_intensity_and_color(d.precipIntensity))
    print(" max precip intensity value = " .. precip_intensity_max_value)
    print("  max precip intensity desc = " .. precip_intensity_max_desc)
    print("  max precip intensity time = " .. precip_intensity_max_time)
    print("                   low temp = " .. dsutils.round(d.temperatureLow))
    print("              low temp time = " .. dsutils.format_date_iso(d.temperatureLowTime))
    print("                  high temp = " .. dsutils.round(d.temperatureHigh))
    print("             high temp time = " .. dsutils.format_date_iso(d.temperatureHighTime))
    print("                 wind speed = " .. ws .. " mph")
    print("             wind direction = " .. wd)
    print("   wind direction full name = " .. wdf)
    print("              max wind gust = " .. wg .. " mph")
    print("         max wind gust time = " .. wgt)
    print("        barometric pressure = " .. d.pressure .. " mb")
    print("        barometric pressure = " .. dsutils.millibars_to_inches(d.pressure) .. " in")
    print("              dewpoint temp = " .. d.dewPoint)
    print("          relative humidity = " .. dsutils.round(d.humidity * 100) .. "%")
    print("            uv index rating = " .. uvi_rating)
    print("          max uv index time = " .. dsutils.format_date_iso(d.uvIndexTime))
    print("           moon phase value = " .. d.moonPhase)
    print("            moon phase desc = " .. dsutils.get_moon_phase_description(d.moonPhase) .. "\n")
end


print("\nHigh Level Info")
print("        time zone offset = " .. wx.offset)
print("                timezone = " .. wx.timezone)
print("               longitude = " .. wx.longitude)
print("                latitude = " .. wx.latitude)
print("         current summary = " .. wx.currently.summary)
print(" next 60 minutes summary = " .. wx.minutely.summary)
print("   next 48 hours summary = " .. wx.hourly.summary)
print("     next 7 days summary = " .. wx.daily.summary)
print("   current date and time = " .. os.date())

