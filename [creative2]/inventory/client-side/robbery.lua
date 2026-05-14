-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSERVERSTART
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	for Number,v in pairs(Robbery) do
		exports["target"]:AddCircleZone("Robbery:"..Number,v.Coords,0.25,{
			name = "Robbery:"..Number,
			heading = 0.0,
			useZ = true
		},{
			shop = Number,
			Distance = 1.25,
			options = {
				{
					event = "inventory:Robbery",
					tunnel = "server",
					label = "Roubar",
					service = v.Mode
				}
			}
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:EXPLOSION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Explosion")
AddEventHandler("inventory:Explosion",function(Coords)
	AddExplosion(Coords.x,Coords.y,Coords.z,4,1.0,true,false,true)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FREEZE 
-----------------------------------------------------------------------------------------------------------------------------------------
local robberyFrozen = false

RegisterNetEvent("robbery:Freeze")
AddEventHandler("robbery:Freeze", function(toggle)
    robberyFrozen = toggle and true or false

    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)

    if robberyFrozen and IsPedInAnyVehicle(ped, false) then
        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 16)
        Wait(500)
    end

    FreezeEntityPosition(ped, robberyFrozen)
end)


CreateThread(function()
    while true do
        if robberyFrozen then
            DisableControlAction(0, 30,  true) -- A/D
            DisableControlAction(0, 31,  true) -- W/S
            DisableControlAction(0, 21,  true) -- Shift (sprint)
            DisableControlAction(0, 22,  true) -- Espaço (pular)
            DisableControlAction(0, 75,  true) -- sair do veículo
            DisableControlAction(0, 23,  true) -- entrar no veículo
            DisableControlAction(0, 24,  true) -- ataque
            DisableControlAction(0, 25,  true) -- mirar
            DisableControlAction(0, 44,  true) -- cover
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            -- opcionais (descomente se quiser):
            -- DisableControlAction(0, 37,  true) -- weapon wheel
            -- DisableControlAction(0, 289, true) -- inventário (ex.: F2)
            Wait(0)
        else
            Wait(250)
        end
    end
end)

local ConflictRadiusBlip = {}
local ConflictCenterBlip = {}

RegisterNetEvent("conflict:Create")
AddEventHandler("conflict:Create", function(data)
	local id = data.id or ("conflict:"..GetGameTimer())
	local coords = data.coords or vector3(0.0,0.0,0.0)
	local radius = (data.radius or 75.0) + 0.0
	local color = data.color or 26
	local name = data.name or "Zona de Conflito"
	local alpha = 180
	local sprite = 161
	local scale = 0.7
	local durMs = math.floor((data.duration or 360) * 1000)

	if ConflictRadiusBlip[id] then RemoveBlip(ConflictRadiusBlip[id]) ConflictRadiusBlip[id] = nil end
	if ConflictCenterBlip[id] then RemoveBlip(ConflictCenterBlip[id]) ConflictCenterBlip[id] = nil end

	local rBlip = AddBlipForRadius(coords, radius)
	SetBlipAlpha(rBlip, alpha)
	SetBlipColour(rBlip, color)
	ConflictRadiusBlip[id] = rBlip

	local cBlip = AddBlipForCoord(coords)
	SetBlipSprite(cBlip, sprite)
	SetBlipDisplay(cBlip, 4)
	SetBlipScale(cBlip, scale)
	SetBlipColour(cBlip, color)
	SetBlipAsShortRange(cBlip, false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(name)
	EndTextCommandSetBlipName(cBlip)
	ConflictCenterBlip[id] = cBlip

	local expireAt = GetGameTimer() + durMs
	CreateThread(function()
		while GetGameTimer() < expireAt do
			Wait(500)
		end
		if ConflictRadiusBlip[id] then RemoveBlip(ConflictRadiusBlip[id]) ConflictRadiusBlip[id] = nil end
		if ConflictCenterBlip[id] then RemoveBlip(ConflictCenterBlip[id]) ConflictCenterBlip[id] = nil end
	end)
end)