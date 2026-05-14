-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
GlobalState.Work = 0
GlobalState.Hours = 10
GlobalState.Players = 0
GlobalState.Minutes = 0
GlobalState.WeatherN = "EXTRASUNNY"
GlobalState.WeatherS = "EXTRASUNNY"
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYNC
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		GlobalState.Work = GlobalState.Work + 1
		GlobalState.Minutes = GlobalState.Minutes + 1

		if GlobalState.Minutes >= 60 then
			GlobalState.Hours = GlobalState.Hours + 1
			GlobalState.Minutes = 0

			if GlobalState.Hours >= 24 then
				GlobalState.Hours = 0

				local SetNewWeather = function(WeatherKey)
                    repeat
                        RandWeather = RandPercentage(WeatherList[WeatherKey])
                    until GlobalState[WeatherKey] ~= RandWeather.Weather

                    GlobalState[WeatherKey] = RandWeather.Weather
                end

                SetNewWeather("WeatherS")
                SetNewWeather("WeatherN")
			end
		end

		Wait(10000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMESET
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("timeset",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		local Keyboard = vKEYBOARD.Timeset(source,"Hora","Minuto")
		if Keyboard then
			local Hours = parseInt(Keyboard[1])
			local Minutes = parseInt(Keyboard[2])

			if Hours >= 24 or Hours <= 0 then
				Hours = 0
			end

			if Minutes >= 60 or Minutes <= 0 then
				Minutes = 0
			end

			GlobalState.Hours = Hours
			GlobalState.Minutes = Minutes
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLIMA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("clima",function(Source)
	local Passport = vRP.Passport(Source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		local Location = { "Sul","Norte" }
		local Weathers = { "EXTRASUNNY","CLEAR","CLOUDS","SMOG","FOGGY","OVERCAST","RAIN","THUNDER","CLEARING","NEUTRAL","SNOW","BLIZZARD","SNOWLIGHT","XMAS","HALLOWEEN" }

		local Keyboard = vKEYBOARD.Weather(Source,Location,Weathers)
		if Keyboard then
			local RegionMap = {
				Sul = { State = "WeatherS", Label = "Sul" },
				Norte = { State = "WeatherN", Label = "Norte" }
			}
			local Region = RegionMap[Keyboard[1]]
			if Region then
				GlobalState[Region.State] = Keyboard[2]
				TriggerClientEvent("Notify",Source,"Sucesso","Você mudou o clima do(a) <b>"..Region.Label.."</b>.","verde",5000)
			end
		end
	end
end)