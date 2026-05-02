-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("engine")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local isPrice = 0
local lastFuel = 0
local LastPump = 0
local pumpGunInHand = false
local PumpCoords = vec3(0.0, 0.0, 0.0)
local PumpConfig = {}
local currentPumpEntity = nil
local vehFuels = {}
local isFuel = false
local showNui = false
local gameTimer = GetGameTimer()
local lastGameTimer = GetGameTimer()
local fuelingTickTimer = 0
local fuelingTickMs = 250
local fuelingStep = 0.50
local enableHoseLine = true
local hoseRibbonHalfWidth = 0.018
local hoseMaxSegments = 14

local function drawHoseRibbonSegment(sx, sy, sz, ex, ey, ez, halfWidth, r, g, b, a)
	local vx = ex - sx
	local vy = ey - sy
	local len = math.sqrt((vx * vx) + (vy * vy))
	if len <= 0.0001 then
		return
	end

	local nx = vx / len
	local ny = vy / len
	local px = -ny
	local py = nx

	local ax = sx + (px * halfWidth)
	local ay = sy + (py * halfWidth)
	local az = sz
	local bx = sx - (px * halfWidth)
	local by = sy - (py * halfWidth)
	local bz = sz
	local cx = ex + (px * halfWidth)
	local cy = ey + (py * halfWidth)
	local cz = ez
	local dx = ex - (px * halfWidth)
	local dy = ey - (py * halfWidth)
	local dz = ez

	DrawPoly(ax, ay, az, bx, by, bz, cx, cy, cz, r, g, b, a)
	DrawPoly(bx, by, bz, dx, dy, dz, cx, cy, cz, r, g, b, a)
end

local function playNozzlePullAnim(ped)
	loadAnim("melee@unarmed@streamed_variations")
	TaskPlayAnim(ped, "melee@unarmed@streamed_variations", "plyr_takedown_rear_righthook", 4.0, 4.0, 220, 48, 0.0, false,
		false,
		false)
	Wait(180)
	ClearPedTasks(ped)
end

local function clearPumpNozzle()
	pumpGunInHand = false
	isFuel = false
	showNui = false
	isPrice = 0

	SendNUIMessage({ show = false })
	StopAnimTask(PlayerPedId(), "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0)
	RemoveAnimDict("timetable@gardener@filling_can")

	if currentPumpEntity and DoesEntityExist(currentPumpEntity) then
		DetachEntity(currentPumpEntity, false, false)
		DeleteEntity(currentPumpEntity)
	end

	currentPumpEntity = nil
	LastPump = nil
end

local function getVehicleFuelLabel(vehicle, vehPlate)
	local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
	if modelName == nil or modelName == "" or modelName == "CARNOTFOUND" then
		modelName = "Desconhecido"
	end

	local translatedModel = GetLabelText(modelName)
	if translatedModel ~= nil and translatedModel ~= "NULL" then
		modelName = translatedModel
	end

	return modelName .. " [" .. vehPlate .. "]"
end

local function drawPumpHoseLine()
	if not enableHoseLine or not pumpGunInHand then
		return
	end

	if not LastPump or LastPump == 0 or not currentPumpEntity or currentPumpEntity == 0 then
		return
	end

	if not DoesEntityExist(LastPump) or not DoesEntityExist(currentPumpEntity) then
		return
	end

	local startX = PumpCoords.x + (PumpConfig[2] or 0.0)
	local startY = PumpCoords.y + (PumpConfig[3] or 0.0)
	local startZ = PumpCoords.z + (PumpConfig[4] or 2.3)
	local endCoords = GetOffsetFromEntityInWorldCoords(currentPumpEntity, 0.0, -0.02, -0.175)

	local distVecX = endCoords.x - startX
	local distVecY = endCoords.y - startY
	local distVecZ = endCoords.z - startZ
	local dist = math.sqrt((distVecX * distVecX) + (distVecY * distVecY) + (distVecZ * distVecZ))
	if dist <= 0.001 then
		return
	end

	local segments = math.floor(math.min(hoseMaxSegments, math.max(6, dist * 2.2)))
	local sag = math.min(0.55, math.max(0.12, dist * 0.12))
	local wave = math.sin(GetGameTimer() * 0.004) * math.min(0.035, dist * 0.01)

	local midX = (startX + endCoords.x) * 0.5
	local midY = (startY + endCoords.y) * 0.5
	local midZ = ((startZ + endCoords.z) * 0.5) - sag
	local controlX = midX + wave
	local controlY = midY - wave
	local controlZ = midZ

	for i = 1, segments do
		local t0 = (i - 1) / segments
		local t1 = i / segments
		local omt0 = 1.0 - t0
		local omt1 = 1.0 - t1

		local p0x = (omt0 * omt0 * startX) + (2.0 * omt0 * t0 * controlX) + (t0 * t0 * endCoords.x)
		local p0y = (omt0 * omt0 * startY) + (2.0 * omt0 * t0 * controlY) + (t0 * t0 * endCoords.y)
		local p0z = (omt0 * omt0 * startZ) + (2.0 * omt0 * t0 * controlZ) + (t0 * t0 * endCoords.z)

		local p1x = (omt1 * omt1 * startX) + (2.0 * omt1 * t1 * controlX) + (t1 * t1 * endCoords.x)
		local p1y = (omt1 * omt1 * startY) + (2.0 * omt1 * t1 * controlY) + (t1 * t1 * endCoords.y)
		local p1z = (omt1 * omt1 * startZ) + (2.0 * omt1 * t1 * controlZ) + (t1 * t1 * endCoords.z)

		local width = hoseRibbonHalfWidth * (1.0 - (t0 * 0.12))
		drawHoseRibbonSegment(p0x, p0y, p0z, p1x, p1y, p1z, width, 28, 28, 28, 230)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GAMEEVENTTRIGGERED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("gameEventTriggered", function(eventName, args)
	if eventName == "CEventNetworkPlayerEnteredVehicle" then
		if args[1] == PlayerId() then
			local vehPlate = GetVehicleNumberPlateText(args[2])
			if GetEntityModel(args[2]) == `rcbandito` then
				vehFuels[vehPlate] = 100.0
			else
				vehFuels[vehPlate] = vSERVER.vehicleFuel(vehPlate)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHCLASS
-----------------------------------------------------------------------------------------------------------------------------------------
local vehClass = {
	[0] = 1.0,
	[1] = 1.0,
	[2] = 1.0,
	[3] = 1.0,
	[4] = 1.0,
	[5] = 1.0,
	[6] = 1.0,
	[7] = 1.0,
	[8] = 1.0,
	[9] = 1.0,
	[10] = 1.0,
	[11] = 1.0,
	[12] = 1.0,
	[13] = 0.0,
	[14] = 0.0,
	[15] = 2.5,
	[16] = 1.0,
	[17] = 1.0,
	[18] = 1.0,
	[19] = 1.0,
	[20] = 1.0,
	[21] = 0.0
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHFUEL
-----------------------------------------------------------------------------------------------------------------------------------------
local vehFuel = {
	[1.0] = 0.80,
	[0.9] = 0.75,
	[0.8] = 0.70,
	[0.7] = 0.65,
	[0.6] = 0.60,
	[0.5] = 0.50,
	[0.4] = 0.40,
	[0.3] = 0.30,
	[0.2] = 0.20,
	[0.1] = 0.10,
	[0.0] = 0.00
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUELLOCS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Radius sempre >= 8.0
local fuelLocs = {
	--	{ 4329.7,7983.2,92.78,5.0,0.001,true,false },
	--	{ 4306.29,7997.75,92.52,5.0,0.001,true,false },
	--	{ 4288.86,8007.55,92.62,5.0,0.001,true,false },
	--	{ 4266.0,8020.11,92.89,5.0,0.001,true,false },
	--	{ 4247.68,8030.23,93.03,5.0,0.001,true,false },
	--	{ 4225.3,8042.8,93.38,5.0,0.001,true,false },
	--	{ 4206.04,8053.39,93.6,5.0,0.001,true,false },
	--	{ 4183.6,8065.84,93.89,5.0,0.001,true,false },
	--	{ 4164.81,8076.03,94.07,5.0,0.001,true,false },
	--	{ 4142.42,8089.06,94.29,5.0,0.001,true,false },
	--	{ 4123.69,8099.21,94.53,5.0,0.001,true,false },
	--	{ 4100.91,8111.77,94.88,5.0,0.001,true,false },
	["1"] = { -2096.24, -320.21, 13.16, 15.0, 0.065, true, false },
	["2"] = { 178.36, 6604.46, 31.86, 10.0, 0.065, true, false },
	["3"] = { 265.05, -1262.65, 29.3, 15.0, 0.085, false, false },
	["4"] = { 819.14, -1028.65, 26.41, 15.0, 0.085, false, false },
	["5"] = { 1208.61, -1402.43, 35.23, 15.0, 0.065, false, false },
	["6"] = { 1181.48, -330.26, 69.32, 10.0, 0.075, false, false },
	["7"] = { 621.01, 268.68, 103.09, 15.0, 0.075, false, false },
	["8"] = { 2581.09, 361.79, 108.47, 17.0, 0.055, false, false },
	["9"] = { 175.08, -1562.12, 29.27, 15.0, 0.075, false, false },
	["10"] = { -319.76, -1471.63, 30.55, 17.0, 0.075, false, false },
	["11"] = { 1784.51, 3330.1, 41.27, 8.0, 0.085, false, false },
	["12"] = { 49.42, 2778.8, 58.05, 15.0, 0.055, false, false },
	["13"] = { 264.09, 2606.56, 44.99, 15.0, 0.065, false, false },
	["14"] = { 1039.38, 2671.28, 39.56, 15.0, 0.065, false, false },
	["15"] = { 1207.4, 2659.93, 37.9, 10.0, 0.065, false, false },
	["16"] = { 2539.19, 2594.47, 37.95, 9.0, 0.055, false, false },
	["17"] = { 2679.95, 3264.18, 55.25, 10.0, 0.065, false, false },
	["18"] = { 2005.03, 3774.43, 32.41, 15.0, 0.075, false, false },
	["19"] = { 1687.07, 4929.53, 42.08, 15.0, 0.055, false, false },
	["20"] = { 1701.53, 6415.99, 32.77, 10.0, 0.065, false, false },
	["21"] = { -94.46, 6419.59, 31.48, 15.0, 0.085, false, false },
	["22"] = { -2555.17, 2334.23, 33.08, 16.0, 0.065, false, false },
	["23"] = { -1800.09, 803.54, 138.72, 16.0, 0.065, false, false },
	["24"] = { -1437.0, -276.8, 46.21, 15.0, 0.075, false, false },
	["25"] = { -724.56, -935.97, 19.22, 17.0, 0.075, false, false },
	["26"] = { -525.26, -1211.19, 18.19, 15.0, 0.075, false, false },
	["27"] = { -70.96, -1762.21, 29.54, 15.0, 0.085, false, false },
	["28"] = { -1112.4, -2884.08, 13.93, 30.0, 0.095, false, false }, -- aeroporto
	["29"] = { -2505.68, 4079.25, 38.79, 8.0, 0.075, false, false },
	["30"] = { 2505.42, 4079.81, 38.79, 8.0, 0.075, false, false },
	["31"] = { -705.32, -1465.06, 5.04, 25.0, 0.095, false, false }, -- gaep
	["32"] = { 303.52, -1448.71, 45.52, 25.0, 0.095, false, false }, -- gaep/hospita lado esquerdo
	["33"] = { 317.31, -1460.28, 45.52, 25.0, 0.095, false, false }, -- gaep/hospita lado direito
}

local gasPumpModels = {
	{ GetHashKey("prop_gas_pump_1d"),   0.0, 0.0, 2.3 },
	{ GetHashKey("prop_gas_pump_1a"),   0.0, 0.0, 2.3 },
	{ GetHashKey("prop_gas_pump_1b"),   0.0, 0.0, 2.3 },
	{ GetHashKey("prop_gas_pump_1c"),   0.0, 0.0, 2.3 },
	{ 0x1CF9D53D,                       0.0, 0.0, 2.3 }, -- 486135101 - bomba da groove
	{ GetHashKey("prop_vintage_pump"),  0.0, 0.0, 1.8 },
	{ GetHashKey("prop_gas_pump_old2"), 0.0, 0.0, 1.6 },
	{ GetHashKey("prop_gas_pump_old3"), 0.0, 0.0, 1.6 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ELETRIC
-----------------------------------------------------------------------------------------------------------------------------------------
local Eletric = { --VOLTAR PRA TRUE DEPOIS
	[1392481335] = false,
	[-1529242755] = false,
	[-1848994066] = false,
	[-1622444098] = false,
	[1031562256] = false,
	[-1130810103] = false,
	[-1132721664] = false,
	[544021352] = false,
	[1147287684] = false,
	[1491375716] = false,
	[1560980623] = false,
	[989294410] = false,
	[-1894894188] = false,
	[-1558566249] = false,
	[1673934297] = false,
	[-1027629791] = false,
	[662793086] = false
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- FLOOR
-----------------------------------------------------------------------------------------------------------------------------------------
function floor(num)
	local mult = 10 ^ 1
	return math.floor(num * mult + 0.5) / mult
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONSUMEFUEL
-----------------------------------------------------------------------------------------------------------------------------------------

CreateThread(function()
	SetNuiFocus(false, false)

	while true do
		local timeDistance = 999
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsUsing(ped)
			local speed = GetEntitySpeed(vehicle) * 2.236936
			if GetVehicleFuelLevel(vehicle) >= 1 then
				if speed >= 1 then
					local vehPlate = GetVehicleNumberPlateText(vehicle)

					if vehFuels[vehPlate] ~= nil then
						local vehClasses = GetVehicleClass(vehicle)

						vehFuels[vehPlate] = (vehFuels[vehPlate] - (vehFuel[floor(GetVehicleCurrentRpm(vehicle))] or 1.0) * (vehClass[vehClasses] or 1.0) / 10)
						SetVehicleFuelLevel(vehicle, vehFuels[vehPlate])
					end

					if GetPedInVehicleSeat(vehicle, -1) == ped then
						TriggerServerEvent("engine:tryFuel", vehPlate, vehFuels[vehPlate])
					end
				end
			else
				SetVehicleEngineOn(vehicle, false, true, true)
				timeDistance = 1
			end
		end

		Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREDREFUEL
-----------------------------------------------------------------------------------------------------------------------------------------
local vehiclesBlacklist = {
	[`kwid`] = true,
	[`betazoe`] = true
}


CreateThread(function()
	while true do
		local timeDistance = 999
		if LocalPlayer["state"]["Route"] < 900000 then
			local ped = PlayerPedId()
			if not IsPedInAnyVehicle(ped) then
				local vehicle = GetPlayersLastVehicle()
				local vehModel = GetEntityModel(vehicle)
				if GetSelectedPedWeapon(ped) == 883325847 then
					if DoesEntityExist(vehicle) and not vehiclesBlacklist[vehModel] then
						local coords = GetEntityCoords(ped)
						local coordsVeh = GetEntityCoords(vehicle)
						local vehFuel = GetVehicleFuelLevel(vehicle)
						local vehPlate = GetVehicleNumberPlateText(vehicle)
						local distance = #(coords - vector3(coordsVeh["x"], coordsVeh["y"], coordsVeh["z"]))
						if distance <= 3.5 then
							timeDistance = 1

							if not isFuel then
								if GetAmmoInPedWeapon(ped, 883325847) - 0.02 * 100 <= 1 then
									text3D(coordsVeh["x"], coordsVeh["y"], coordsVeh["z"] + 1, "~b~GALÃO VAZIO")
								elseif vehFuel < 100.0 then
									text3D(coordsVeh["x"], coordsVeh["y"], coordsVeh["z"] + 1, "~g~E~w~   ABASTECER")
								end
							else
								if GetAmmoInPedWeapon(ped, 883325847) - 0.02 * 100 > 1 then
									SetPedAmmo(ped, 883325847, math.floor(GetAmmoInPedWeapon(ped, 883325847) - 0.02 * 100))

									SetVehicleFuelLevel(vehicle, vehFuel + 0.025)
									text3D(coordsVeh["x"], coordsVeh["y"], coordsVeh["z"] + 1, "~g~E~w~   CANCELAR")
									text3D(coordsVeh["x"], coordsVeh["y"], coordsVeh["z"] + 0.85,
										"TANQUE: ~y~" ..
										parseInt(floor(vehFuel)) ..
										"%   ~w~GALÃO: ~y~" .. parseInt(GetAmmoInPedWeapon(ped, 883325847) / 4500 * 100) .. "%")

									if not IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
										TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3.0, 3.0, -1, 50, 0, 0, 0,
											0)
									end

									if vehFuel >= 100.0 or GetAmmoInPedWeapon(ped, 883325847) - 0.02 * 100 <= 1 or GetEntityHealth(ped) <= 101 then
										TriggerServerEvent("engine:tryFuel", vehPlate, vehFuel)
										StopAnimTask(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0)
										RemoveAnimDict("timetable@gardener@filling_can")
										isFuel = false
									end
								end
							end

							if IsControlJustPressed(1, 38) and GetGameTimer() >= gameTimer then
								gameTimer = GetGameTimer() + 3000

								if isFuel then
									TriggerServerEvent("engine:tryFuel", vehPlate, vehFuel)
									StopAnimTask(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0)
									RemoveAnimDict("timetable@gardener@filling_can")
									isFuel = false
								else
									if GetAmmoInPedWeapon(ped, 883325847) - 0.02 * 100 >= 0 and vehFuel <= 100.0 then
										TaskTurnPedToFaceEntity(ped, vehicle, 5000)
										loadAnim("timetable@gardener@filling_can")
										TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3.0, 3.0, -1, 50, 0, 0, 0,
											0)
										isFuel = true
									end
								end
							end
						end

						if isFuel and distance > 3.5 then
							TriggerServerEvent("engine:tryFuel", vehPlate, vehFuel)
							StopAnimTask(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0)
							RemoveAnimDict("timetable@gardener@filling_can")
							isFuel = false
						end
					end
				else
					local coords = GetEntityCoords(ped)

					for _, v in pairs(fuelLocs) do
						local distance = #(coords - vector3(v[1], v[2], v[3]))
						if distance <= v[4] and ((v[7] and Eletric[vehModel]) or (not v[7] and not Eletric[vehModel])) then
							timeDistance = 1
							local vehicle = GetPlayersLastVehicle()
							if DoesEntityExist(vehicle) and not vehiclesBlacklist[vehModel] then
								local coordsVeh = GetEntityCoords(vehicle)
								local vehFuel = GetVehicleFuelLevel(vehicle)
								local vehPlate = GetVehicleNumberPlateText(vehicle)
								local distanceToVeh = #(coords - vector3(coordsVeh["x"], coordsVeh["y"], coordsVeh["z"]))

								if not pumpGunInHand then
									for _, p in ipairs(gasPumpModels) do
										LastPump = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.5, p[1], false, false, false)
										if LastPump and DoesEntityExist(LastPump) then
											PumpCoords = GetEntityCoords(LastPump)
											PumpConfig = p
											break
										end
									end
								end
								local distanceToPump = #(coords - PumpCoords)
								local vehLabel = getVehicleFuelLabel(vehicle, vehPlate)
								drawPumpHoseLine()

								if distanceToPump > 5.0 and pumpGunInHand then
									clearPumpNozzle()
								end

								if not pumpGunInHand and distanceToPump < 2.0 and vehFuel < 100.0 then
									text3D(PumpCoords.x, PumpCoords.y, PumpCoords.z + 1, "~g~E~w~   ABRIR")

									if IsControlJustPressed(1, 38) and GetGameTimer() >= gameTimer then
										pumpGunInHand = true
										isFuel = false
										isPrice = 0
										gameTimer = GetGameTimer() + 800
										vRP.removeObjects("one")
										playNozzlePullAnim(ped)
										Wait(180)
										LoadModel(`prop_cs_fuel_nozle`)
										currentPumpEntity = CreateObjectNoOffset(`prop_cs_fuel_nozle`, coords.x, coords.y, coords.z, false,
											false, false)
										if DoesEntityExist(currentPumpEntity) then
											SetEntityCollision(currentPumpEntity, false, false)
											AttachEntityToEntity(currentPumpEntity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.055,
												0.05, 0.0, -50.0, -90.0, -50.0, true, true, false, true, 0, true)
											local Title = "Posto de Gasolina"
											local Legends = "Abastecimento de combustível"
											local Background = "url(background.png) rgba(15,15,15,.75)"

											SendNUIMessage({
												show = true,
												background = Background,
												title = Title,
												legends = Legends,
												vehicle = vehLabel
											})
											SendNUIMessage({
												tank = parseInt(floor(vehFuel)),
												price = parseInt(isPrice),
												lts = 0
											})
											showNui = true
										else
											pumpGunInHand = false
											LastPump = nil
										end
									end
								end

								if pumpGunInHand and distanceToVeh <= 3.5 then
									local wheelCoords = GetWorldPositionOfEntityBone(vehicle,
										GetEntityBoneIndexByName(vehicle, "wheel_lr"))
									local ePressed = IsControlJustPressed(1, 38) and GetGameTimer() >= gameTimer

									if not isFuel then
										text3D(PumpCoords.x, PumpCoords.y, PumpCoords.z + 1, "~g~BACKSPACE~w~   Cancelar")
										if IsControlJustPressed(1, 177) then
											clearPumpNozzle()
										end

										if vehFuel < 100.0 then
											text3D(wheelCoords["x"], wheelCoords["y"], wheelCoords["z"] + 1,
												"~g~E~w~   ABASTECER")
										end
									else
										if fuelingTickTimer <= GetGameTimer() then
											local priceMultiplier = fuelingStep / 0.025
											isPrice = isPrice + (v[5] * priceMultiplier)
											SetVehicleFuelLevel(vehicle, vehFuel + fuelingStep)
											fuelingTickTimer = GetGameTimer() + fuelingTickMs
										end

										vehFuel = GetVehicleFuelLevel(vehicle)
										local ltsPerSecond = (v[5] * (fuelingStep / 0.025)) * (1000 / fuelingTickMs)
										SendNUIMessage({
											tank = parseInt(floor(vehFuel)),
											price = parseInt(isPrice),
											lts = ltsPerSecond,
											vehicle = vehLabel
										})
										text3D(wheelCoords["x"], wheelCoords["y"], wheelCoords["z"] + 1,
											"~g~E~w~   FINALIZAR")

										if not IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
											TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3.0, 3.0, -1, 50, 0, 0,
												0, 0)
										end

										local explodePump = false
										if lastGameTimer < GetGameTimer() and GetIsVehicleEngineRunning(vehicle) then
											lastGameTimer = GetGameTimer() + 1000
											local Chance = math.random(100)
											if Chance < 39 then
												explodePump = true
												AddExplosion(coords.x, coords.y, coords.z, 2, 1.0, 1.0, true, true, false)
											end
										end

										if vehFuel >= 100.0 or GetEntityHealth(ped) <= 101 or explodePump then
											local Kmv = 0
											if v[6] then
												Kmv = isPrice * 0.25
											end

											if vSERVER.paymentFuel(isPrice, vehPlate, vehFuel, Kmv) then
												TriggerServerEvent("engine:tryFuel", vehPlate, vehFuel)
												vehFuels[vehPlate] = vehFuel
											else
												TriggerServerEvent("engine:tryFuel", vehPlate, lastFuel)
												vehFuels[vehPlate] = lastFuel
											end

											StopAnimTask(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0)
											RemoveAnimDict("timetable@gardener@filling_can")
											SendNUIMessage({ show = false })
											showNui = false
											isFuel = false
											isPrice = 0

											clearPumpNozzle()
										end
									end

									if ePressed then
										gameTimer = GetGameTimer() + 800

										if isFuel then
											local Kmv = 0
											if v[6] then
												Kmv = isPrice * 0.25
											end

											if vSERVER.paymentFuel(isPrice, vehPlate, vehFuel, Kmv) then
												TriggerServerEvent("engine:tryFuel", vehPlate, vehFuel)
												vehFuels[vehPlate] = vehFuel
											else
												TriggerServerEvent("engine:tryFuel", vehPlate, lastFuel)
												vehFuels[vehPlate] = lastFuel
											end

											StopAnimTask(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0)
											RemoveAnimDict("timetable@gardener@filling_can")
											SendNUIMessage({ show = false })
											showNui = false
											isFuel = false
											isPrice = 0

											clearPumpNozzle()
										elseif vehFuel < 100.0 then
											lastFuel = vehFuel
											fuelingTickTimer = 0
											TaskTurnPedToFaceEntity(ped, vehicle, 5000)
											loadAnim("timetable@gardener@filling_can")
											TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3.0, 3.0, -1, 50, 0,
												0, 0, 0)
											isFuel = true
										end
									end
								end

								if isFuel and distanceToVeh > 3.5 then
									if vSERVER.paymentFuel(isPrice, vehPlate, vehFuel) then
										TriggerServerEvent("engine:tryFuel", vehPlate, vehFuel)
										vehFuels[vehPlate] = vehFuel
									else
										TriggerServerEvent("engine:tryFuel", vehPlate, lastFuel)
										vehFuels[vehPlate] = lastFuel
									end

									StopAnimTask(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0)
									RemoveAnimDict("timetable@gardener@filling_can")
									SendNUIMessage({ show = false })
									showNui = false
									isFuel = false
									isPrice = 0

									clearPumpNozzle()
								end
							end
						end
					end
				end

				if isFuel then
					DisableControlAction(1, 18, true)
					DisableControlAction(1, 22, true)
					DisableControlAction(1, 23, true)
					DisableControlAction(1, 24, true)
					DisableControlAction(1, 29, true)
					DisableControlAction(1, 30, true)
					DisableControlAction(1, 31, true)
					DisableControlAction(1, 140, true)
					DisableControlAction(1, 142, true)
					DisableControlAction(1, 143, true)
					DisableControlAction(1, 257, true)
					DisableControlAction(1, 263, true)
				end

				if showNui and not pumpGunInHand then
					SendNUIMessage({ show = false })
					showNui = false
				end
			end
		end

		Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCFUEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("engine:syncFuel")
AddEventHandler("engine:syncFuel", function(vehPlate, vehResult)
	if vehPlate then
		local fuelValue = tonumber(vehResult)
		if fuelValue then
			vehFuels[vehPlate] = fuelValue
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEXT3D
-----------------------------------------------------------------------------------------------------------------------------------------
function text3D(x, y, z, text)
	local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)

	if onScreen then
		BeginTextCommandDisplayText("STRING")
		AddTextComponentSubstringKeyboardDisplay(text)
		SetTextColour(255, 255, 255, 150)
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextCentre(1)
		EndTextCommandDisplayText(_x, _y)

		local width = (string.len(text) + 4) / 170 * 0.45
		DrawRect(_x, _y + 0.0125, width, 0.03, 38, 42, 56, 200)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADANIM
-----------------------------------------------------------------------------------------------------------------------------------------
function loadAnim(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(1)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADMODEL
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadModel(modelHash)
	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)
		while not HasModelLoaded(modelHash) do
			RequestModel(modelHash)
			Wait(100)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETPOINTINFRONTOFPOSITION
-----------------------------------------------------------------------------------------------------------------------------------------
function GetPointInfrontOfPosition(position, forward, distance)
	return vec3(position.x + forward.x * distance, position.y + forward.y * distance, position.z + forward.z * distance)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- VTUNING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("engine:vehTuning")
AddEventHandler("engine:vehTuning", function()
	local vehicle = vRP.nearVehicle(5)
	if vehicle then
		local motor = GetVehicleMod(vehicle, 11)
		local freio = GetVehicleMod(vehicle, 12)
		local transmissao = GetVehicleMod(vehicle, 13)
		local suspensao = GetVehicleMod(vehicle, 15)
		local blindagem = GetVehicleMod(vehicle, 16)
		local body = GetVehicleBodyHealth(vehicle)
		local engine = GetVehicleEngineHealth(vehicle)
		local fuel = GetVehicleFuelLevel(vehicle)
		local plate = GetVehicleNumberPlateText(vehicle)

		if motor == -1 then
			motor = "Desativado"
		elseif motor == 0 then
			motor = "Nível 1 / " .. GetNumVehicleMods(vehicle, 11)
		elseif motor == 1 then
			motor = "Nível 2 / " .. GetNumVehicleMods(vehicle, 11)
		elseif motor == 2 then
			motor = "Nível 3 / " .. GetNumVehicleMods(vehicle, 11)
		elseif motor == 3 then
			motor = "Nível 4 / " .. GetNumVehicleMods(vehicle, 11)
		elseif motor == 4 then
			motor = "Nível 5 / " .. GetNumVehicleMods(vehicle, 11)
		end

		if freio == -1 then
			freio = "Desativado"
		elseif freio == 0 then
			freio = "Nível 1 / " .. GetNumVehicleMods(vehicle, 12)
		elseif freio == 1 then
			freio = "Nível 2 / " .. GetNumVehicleMods(vehicle, 12)
		elseif freio == 2 then
			freio = "Nível 3 / " .. GetNumVehicleMods(vehicle, 12)
		end

		if transmissao == -1 then
			transmissao = "Desativado"
		elseif transmissao == 0 then
			transmissao = "Nível 1 / " .. GetNumVehicleMods(vehicle, 13)
		elseif transmissao == 1 then
			transmissao = "Nível 2 / " .. GetNumVehicleMods(vehicle, 13)
		elseif transmissao == 2 then
			transmissao = "Nível 3 / " .. GetNumVehicleMods(vehicle, 13)
		elseif transmissao == 3 then
			transmissao = "Nível 4 / " .. GetNumVehicleMods(vehicle, 13)
		end

		if suspensao == -1 then
			suspensao = "Desativado"
		elseif suspensao == 0 then
			suspensao = "Nível 1 / " .. GetNumVehicleMods(vehicle, 15)
		elseif suspensao == 1 then
			suspensao = "Nível 2 / " .. GetNumVehicleMods(vehicle, 15)
		elseif suspensao == 2 then
			suspensao = "Nível 3 / " .. GetNumVehicleMods(vehicle, 15)
		elseif suspensao == 3 then
			suspensao = "Nível 4 / " .. GetNumVehicleMods(vehicle, 15)
		elseif suspensao == 4 then
			suspensao = "Nível 5 / " .. GetNumVehicleMods(vehicle, 15)
		end

		if blindagem == -1 then
			blindagem = "Desativado"
		elseif blindagem == 0 then
			blindagem = "Nível 1 / " .. GetNumVehicleMods(vehicle, 16)
		elseif blindagem == 1 then
			blindagem = "Nível 2 / " .. GetNumVehicleMods(vehicle, 16)
		elseif blindagem == 2 then
			blindagem = "Nível 3 / " .. GetNumVehicleMods(vehicle, 16)
		elseif blindagem == 3 then
			blindagem = "Nível 4 / " .. GetNumVehicleMods(vehicle, 16)
		elseif blindagem == 4 then
			blindagem = "Nível 5 / " .. GetNumVehicleMods(vehicle, 16)
		end

		TriggerEvent("Notify", "default",
			"<b>Motor:</b> " ..
			motor ..
			"<br><b>Freio:</b> " ..
			freio ..
			"<br><b>Transmissão:</b> " ..
			transmissao ..
			"<br><b>Suspensão:</b> " ..
			suspensao ..
			"<br><b>Blindagem:</b> " ..
			blindagem ..
			"<br><b>Lataria:</b> " ..
			parseInt(body / 10) ..
			"%<br><b>Nitro:</b> " ..
			parseInt((GlobalState["Nitro"][plate] or 0) / 10) ..
			"%<br><b>Motor:</b> " .. parseInt(engine / 10) .. "%<br><b>Gasolina:</b> " .. parseInt(fuel) .. "%", 10000)
	end
end)
