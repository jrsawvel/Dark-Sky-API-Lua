# Dark-Sky-API-Lua


This Lua wrapper, `darksky.lua`, is used to fetch the excellent weather data, provided in JSON format by [DarkSky.net](https://darksky.net), formerly called forecast.io. 

Related: 

* [DarkSky.net developer API info](https://darksky.net/dev). 


From the Dark Sky [docs](https://darksky.net/dev/docs) page:

> The Dark Sky API allows you to look up the weather anywhere on the globe, returning (where available):

> * Current weather conditions
* Minute-by-minute forecasts out to one hour
* Hour-by-hour and day-by-day forecasts out to seven days
* Hour-by-hour and day-by-day observations going back decades

The repo also includes utilities, `dsutils.lua`, that can format the Dark Sky data to be more reader-friendly.

A working example that uses this Lua code can be found at [my Lua version of ToledoWeather.info](http://toledoweatherlua.soupmode.com). This weather Web app uses jQuery mobile on the client side. Several Lua  scripts execute at different intervals in cron that fetch RSS, custom XML, JSON, HTML, and plain text files from the National Weather Service to provide the data for display. The [Dark Sky section](http://toledoweatherlua.soupmode.com./darksky.html) of this Web app uses this Lua module. Code for the entire Lua version of the Toledo weather Web app exists on GitHub at [ToledoWX-Lua](https://github.com/jrsawvel/ToledoWX-Lua).

This code was inspired by my [Perl Dark Sky module](https://github.com/jrsawvel/Perl-ForecastIO).



*created March 2018*

