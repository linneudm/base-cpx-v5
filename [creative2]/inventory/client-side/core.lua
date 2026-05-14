_RegisterCommand = RegisterCommand
function RegisterCommand(command, callback)
    _RegisterCommand(command, function(...)
        if not LocalPlayer.state.inComboEvent then
            return callback(...)
        end
    end)
end

_IsControlJustPressed = IsControlJustPressed
function IsControlJustPressed(...)
    if LocalPlayer.state.inComboEvent then
        return false
    else
        return _IsControlJustPressed(...)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPS = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("inventory",Creative)
vGARAGE = Tunnel.getInterface("garages")
vSERVER = Tunnel.getInterface("inventory")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Types = ""
Actived = false
local Swimming = false
local ShotDelay = GetGameTimer()
LocalPlayer["state"]["RecoilReducer"] = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- RECOILCONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
local RecoilConfig = {
    -- PADRÃO DE CONFIGURAÇÃO
    -- ["NOME_ARMA"] = { RECOIL_A_PÉ, RECOIL_NO_VEÍCULO },
	["WEAPON_COMBATPISTOL"] = { 0.0, 0.1 },
    ["WEAPON_COLTXM177"] = { 0.0, 0.1 },
    ["WEAPON_HEAVYPISTOL"] = { 0.0, 0.1 },
    ["WEAPON_PISTOL"] = { 0.0, 0.1 },
    ["WEAPON_COMPACTRIFLE"] = { 0.0, 0.1 }, -- sobrescrevendo pelo meta
    ["WEAPON_SNSPISTOL_MK2"] = { 0.0, 0.1 }, -- sobrescrevendo pelo meta
    ["WEAPON_PISTOL_MK2"] = { 0.0, 0.1 },
    ["WEAPON_MACHINEPISTOL"] = { 0.0, 0.1 },
    ["WEAPON_SMG_MK2"] = { 0.0, 0.1 },
	["WEAPON_MICROSMG"] = { 0.0, 0.1 },
	["WEAPON_MINISMG"] = { 0.0, 0.1 },
	["WEAPON_GLOCKRAJADA"] = { 0.0, 0.1 },
    ["WEAPON_GLOCKNORM"] = { 0.0, 0.1 },
	["WEAPON_ASSAULTSMG"] = { 0.0, 0.1 },
	["WEAPON_ASSAULTRIFLE"] = { 0.0, 0.1 },
	["WEAPON_ASSAULTRIFLE_MK2"] = { 0.0, 0.1 },
	["WEAPON_SPECIALCARBINE"] = { 0.0, 0.1 },
	["WEAPON_SPECIALCARBINE_MK2"] = { 0.0, 0.1 },
	["WEAPON_SMG"] = { 0.0, 0.1 },
	["WEAPON_TACTICALRIFLE"] = { 0.0, 0.1 },
	["WEAPON_aktamb"] = { 0.0, 0.1 },
	["WEAPON_BCM4"] = { 0.0, 0.1 },
	["WEAPON_FAL"] = { 0.0, 0.1 },
	["WEAPON_HK416"] = { 0.0, 0.1 },
	["WEAPON_M4BAL"] = { 0.0, 0.1 },
	["WEAPON_M16A4CAMMO"] = { 0.0, 0.1 },
	["WEAPON_M16A4TCP"] = { 0.0, 0.1 },
	["WEAPON_PARAFAL"] = { 0.0, 0.1 },
	["WEAPON_M4GOLD"] = { 0.0, 0.1 },
	["WEAPON_HK417DENDE"] = { 0.0, 0.1 },
	["WEAPON_GLOCKRELIKIASHOPFEMININO"] = { 0.0, 0.1 },
	["WEAPON_G3RELIKIASHOPFEMININO"] = { 0.0, 0.1 },
	["WEAPON_ARRELIKIASHOPFEMININO1"] = { 0.0, 0.1 },
	["WEAPON_COMPACTRIFLE"] = { 0.0, 0.1 },
	["WEAPON_APPISTOL"] = { 0.0, 0.1 },
	["WEAPON_CARBINERIFLE"] = { 0.0, 0.1 },
	["WEAPON_CARBINERIFLE_MK2"] = { 0.0, 0.1 },
	["WEAPON_ADVANCEDRIFLE"] = { 0.0, 0.1 },
	["WEAPON_BULLPUPRIFLE"] = { 0.0, 0.1 },
	["WEAPON_BULLPUPRIFLE_MK2"] = { 0.0, 0.1 },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSHOT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("CEventGunShot",function(_,OtherPeds)
	local Ped = PlayerPedId()
	if Ped == OtherPeds then
		if IsPedInAnyVehicle(Ped) then
			if Weapon ~= "" and RecoilConfig[Weapon] then
				if LocalPlayer["state"]["RecoilReducer"] and Weapon == LocalPlayer["state"]["RecoilReducer"] then
					ActualRecoil = RecoilConfig[Weapon][2] / 2
				else
					ActualRecoil = RecoilConfig[Weapon][2]
				end
				ShakeGameplayCam("SMALL_EXPLOSION_SHAKE",ActualRecoil)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBLOCKBUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped = PlayerPedId()
		if LocalPlayer["state"]["Buttons"] then
			DisableControlAction(0,257,true)
			DisableControlAction(0,75,true)
			DisableControlAction(0,47,true)
			DisablePlayerFiring(Ped,true)

			TimeDistance = 1
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CLEARNER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("inventory:Cleaner",function(Ped)
	if LocalPlayer.state.inComboEvent then 
		return 
	end
	TriggerEvent("hud:Weapon",false)
	RemoveAllPedWeapons(Ped,true)
	TriggerEvent("Weapon","")
	Actived = false
	Weapon = ""
	Types = ""
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REPAIRBOOSTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:RepairBoosts")
AddEventHandler("inventory:RepairBoosts",function(Index,Plate)
	if NetworkDoesNetworkIdExist(Index) then
		local Vehicle = NetToEnt(Index)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			local Tyres = {}

			for i = 0,7 do
				local Status = false

				if GetTyreHealth(Vehicle,i) ~= 1000.0 then
					Status = true
				end

				Tyres[i] = Status
			end

			local Fuel = GetVehicleFuelLevel(Vehicle)

			SetVehicleUndriveable(Vehicle,false)
			SetVehicleFixed(Vehicle)
			SetVehicleDirtLevel(Vehicle,0.0)
			SetVehicleDeformationFixed(Vehicle)
			SetVehicleFuelLevel(Vehicle,Fuel)

			for Tyre,Burst in pairs(Tyres) do
				if Burst then
					SetVehicleTyreBurst(Vehicle,Tyre,true,1000.0)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REPAIRTYRES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:RepairTyres")
AddEventHandler("inventory:RepairTyres",function(Vehicle,Tyres,Plate)
	if NetworkDoesNetworkIdExist(Vehicle) then
		local Vehicle = NetToEnt(Vehicle)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			if Tyres == "All" then
				for i = 0,10 do
					if GetTyreHealth(Vehicle,i) ~= 1000.0 then
						SetVehicleTyreFixed(Vehicle,i)
					end
				end
			else
				for i = 0,10 do
					if GetTyreHealth(Vehicle,i) ~= 1000.0 then
						SetVehicleTyreBurst(Vehicle,i,true,1000.0)
					end
				end

				SetVehicleTyreFixed(Vehicle,Tyres)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REPAIRDEFAULT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:RepairDefault")
AddEventHandler("inventory:RepairDefault",function(Index,Plate)
	if NetworkDoesNetworkIdExist(Index) then
		local Vehicle = NetToEnt(Index)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			SetVehicleEngineHealth(Vehicle,1000.0)
			SetVehicleBodyHealth(Vehicle,1000.0)
			SetEntityHealth(Vehicle,1000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REPAIRADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:RepairAdmin")
AddEventHandler("inventory:RepairAdmin",function(Index,Plate)
	if NetworkDoesNetworkIdExist(Index) then
		local Vehicle = NetToEnt(Index)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			local Fuel = GetVehicleFuelLevel(Vehicle)

			SetVehicleUndriveable(Vehicle,false)
			SetVehicleFixed(Vehicle)
			SetVehicleDirtLevel(Vehicle,0.0)
			SetVehicleDeformationFixed(Vehicle)
			SetVehicleFuelLevel(Vehicle,Fuel)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WAYPOINT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Waypoint(Coords)
	if Coords.x ~= 0.0 and Coords.y ~= 0.0 then
		SetNewWaypoint(Coords.x + 0.0001,Coords.y + 0.0001)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FISHING
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Fishing()
	local Fishing = false
	local Ped = PlayerPedId()
	if #(GetEntityCoords(Ped) - vec3(-1924.18,-1346.72,14.15)) <= 200 then
		Fishing = true
	end

	return Fishing
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:EXPLODETYRES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:explodeTyres")
AddEventHandler("inventory:explodeTyres",function(Network,Plate,Tyre)
	if NetworkDoesNetworkIdExist(Network) then
		local Vehicle = NetToEnt(Network)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			SetVehicleTyreBurst(Vehicle,Tyre,true,1000.0)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TYRELIST
-----------------------------------------------------------------------------------------------------------------------------------------
local TyreList = {
	["wheel_lf"] = 0,
	["wheel_rf"] = 1,
	["wheel_lm"] = 2,
	["wheel_rm"] = 3,
	["wheel_lr"] = 4,
	["wheel_rr"] = 5
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TYRES
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Tyres()
	local Ped = PlayerPedId()
	if not IsPedInAnyVehicle(Ped) then
		local Vehicle,Model = vRP.ClosestVehicle(7)
		if IsEntityAVehicle(Vehicle) then
			local Coords = GetEntityCoords(Ped)

			for Index,Tyre in pairs(TyreList) do
				local Selected = GetEntityBoneIndexByName(Vehicle,Index)
				if Selected ~= -1 then
					local CoordsWheel = GetWorldPositionOfEntityBone(Vehicle,Selected)
					if #(Coords - CoordsWheel) <= 1.0 and GetTyreHealth(Vehicle,Tyre) ~= 1000.0 then
						return Vehicle,Tyre,VehToNet(Vehicle),GetVehicleNumberPlateText(Vehicle),Model
					end
				end
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TYREHEALTH
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.tyreHealth(Network,Tyre)
	if NetworkDoesNetworkIdExist(Network) then
		local Vehicle = NetToEnt(Network)
		if DoesEntityExist(Vehicle) then
			return GetTyreHealth(Vehicle,Tyre)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OBJECTEXISTS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.ObjectExists(Coords,Hash,Distance)
	return DoesObjectOfTypeExistAtCoords(Coords[1],Coords[2],Coords[3],Distance or 0.35,Hash,true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKINTERIOR
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.CheckInterior()
	return GetInteriorFromEntity(PlayerPedId()) ~= 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOSSANTOS
-----------------------------------------------------------------------------------------------------------------------------------------
local LosSantos = PolyZone:Create({
	vec2(-2153.08,-3131.33),
	vec2(-1581.58,-2092.38),
	vec2(-3271.05,275.85),
	vec2(-3460.83,967.42),
	vec2(-3202.39,1555.39),
	vec2(-1642.50,993.32),
	vec2(312.95,1054.66),
	vec2(1313.70,341.94),
	vec2(1739.01,-1280.58),
	vec2(1427.42,-3440.38),
	vec2(-737.90,-3773.97)
},{ name = "Santos" })
-----------------------------------------------------------------------------------------------------------------------------------------
-- SANDYSHORES
-----------------------------------------------------------------------------------------------------------------------------------------
local SandyShores = PolyZone:Create({
	vec2(-375.38,2910.14),
	vec2(307.66,3664.47),
	vec2(2329.64,4128.52),
	vec2(2349.93,4578.50),
	vec2(1680.57,4462.48),
	vec2(1570.01,4961.27),
	vec2(1967.55,5203.67),
	vec2(2387.14,5273.98),
	vec2(2735.26,4392.21),
	vec2(2512.33,3711.16),
	vec2(1681.79,3387.82),
	vec2(258.85,2920.16)
},{ name = "Sandy" })
-----------------------------------------------------------------------------------------------------------------------------------------
-- PALETOBAY
-----------------------------------------------------------------------------------------------------------------------------------------
local PaletoBay = PolyZone:Create({
	vec2(-529.40,5755.14),
	vec2(-234.39,5978.46),
	vec2(278.16,6381.84),
	vec2(672.67,6434.39),
	vec2(699.56,6877.77),
	vec2(256.59,7058.49),
	vec2(17.64,7054.53),
	vec2(-489.45,6449.50),
	vec2(-717.59,6030.94)
},{ name = "Paleto" })
-----------------------------------------------------------------------------------------------------------------------------------------
-- CEVENTGUNSHOT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("CEventGunShot",function(_,OtherPeds)
	local Ped = PlayerPedId()
	if LocalPlayer.state.inComboEvent then 
        return 
    end 
	if Ped == OtherPeds and not LocalPlayer["state"]["Arena"] and not CheckPolice() and GetGameTimer() >= ShotDelay and Weapon ~= "WEAPON_MUSKET" then
		ShotDelay = GetGameTimer() + 60000
		TriggerEvent("player:Residual","Resíduo de Pólvora")

		local Coords = GetEntityCoords(Ped)
		if not IsPedCurrentWeaponSilenced(Ped) then
			if (LosSantos:isPointInside(Coords) or SandyShores:isPointInside(Coords) or PaletoBay:isPointInside(Coords)) then
				vSERVER.ShotsFired(IsPedInAnyVehicle(Ped))
			end
		else
			if math.random(100) >= 75 and (LosSantos:isPointInside(Coords) or SandyShores:isPointInside(Coords) or PaletoBay:isPointInside(Coords)) then
				vSERVER.ShotsFired(IsPedInAnyVehicle(Ped))
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESTAURANTE:POLYZONE
-----------------------------------------------------------------------------------------------------------------------------------------
local Restaurante = PolyZone:Create({
	vec2(-513.92,-683.55),vec2(-513.65,-683.52),vec2(-513.64,-683.7),vec2(-511.38,-683.7),vec2(-511.39,-683.54),
	vec2(-511.21,-683.53),vec2(-511.3,-678.85),vec2(-510.49,-678.83),vec2(-510.48,-678.34),vec2(-501.96,-678.35),
	vec2(-501.94,-678.89),vec2(-500.91,-678.85),vec2(-500.97,-681.31),vec2(-501.25,-681.3),vec2(-501.27,-687.36),
	vec2(-500.98,-687.39),vec2(-500.98,-689.06),vec2(-501.27,-689.1),vec2(-501.26,-695.81),vec2(-501.01,-695.8),
	vec2(-500.93,-697.29),vec2(-498.83,-697.41),vec2(-498.91,-704.5),vec2(-500.66,-704.51),vec2(-500.65,-704.86),
	vec2(-499.66,-704.86),vec2(-499.67,-708.31),vec2(-500.64,-708.33),vec2(-500.64,-708.89),vec2(-500.36,-708.92),
	vec2(-500.41,-709.73),vec2(-500.66,-709.72),vec2(-500.65,-712.02),vec2(-500.81,-712.07),vec2(-500.81,-713.36),
	vec2(-500.64,-713.43),vec2(-500.63,-714.17),vec2(-500.42,-714.21),vec2(-500.43,-714.95),vec2(-500.66,-714.99),
	vec2(-500.63,-717.36),vec2(-500.42,-717.38),vec2(-500.42,-718.15),vec2(-500.1,-718.14),vec2(-500.09,-721.59),
	vec2(-501.0,-721.59),vec2(-500.99,-721.84),vec2(-500.91,-726.23),vec2(-500.94,-726.45),vec2(-500.67,-726.46),
	vec2(-500.61,-728.13),vec2(-500.86,-728.15),vec2(-500.81,-733.63),vec2(-500.54,-733.66),vec2(-500.5,-735.32),
	vec2(-500.79,-735.36),vec2(-502.19,-736.85),vec2(-502.29,-735.99),vec2(-507.68,-736.29),vec2(-507.71,-737.18),
	vec2(-510.26,-737.27),vec2(-510.92,-736.4),vec2(-510.67,-736.18),vec2(-514.1,-732.04),vec2(-514.44,-732.21),
	vec2(-523.5,-720.17),vec2(-523.77,-720.31),vec2(-524.08,-719.73),vec2(-523.94,-719.61),vec2(-529.74,-706.13),
	vec2(-529.99,-706.18),vec2(-530.13,-705.54),vec2(-529.93,-705.45),vec2(-531.62,-692.63),vec2(-531.87,-692.6),
	vec2(-531.83,-691.97),vec2(-531.59,-691.97),vec2(-531.55,-688.62),vec2(-527.98,-688.53),vec2(-528.04,-688.01),
	vec2(-527.49,-687.81),vec2(-528.22,-685.06),vec2(-529.03,-685.07),vec2(-529.03,-684.36),vec2(-528.19,-684.32),
	vec2(-527.54,-681.71),vec2(-528.19,-681.38),vec2(-527.87,-680.76),vec2(-527.22,-681.07),vec2(-525.2,-679.18),
	vec2(-525.6,-678.46),vec2(-525.02,-678.15),vec2(-524.69,-678.65),vec2(-521.95,-678.15),vec2(-521.94,-677.42),
	vec2(-521.29,-677.44),vec2(-521.24,-678.23),vec2(-518.57,-678.9),vec2(-518.12,-678.26),vec2(-517.56,-678.63),
	vec2(-517.93,-679.25),vec2(-515.92,-681.33),vec2(-514.88,-680.81),vec2(-513.91,-681.97)
},{ name = "Restaurante" })
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESTAURANT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Restaurant()
	local Ped = PlayerPedId()
	local Coords = GetEntityCoords(Ped)

	return Restaurante:isPointInside(Coords)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKPARACHUTE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.CheckParachute()
	return HasPedGotWeapon(PlayerPedId(), GetHashKey("GADGET_PARACHUTE"), false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADLEAVESERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Ped = PlayerPedId()
		if not IsPedInAnyVehicle(Ped) then
			if IsPedSwimming(Ped) then
				if not Swimming and not ScubaTank and not ScubaMask then
					Swimming = true
					vSERVER.Swimming()
				end
			elseif Swimming then
				Swimming = false
			end
		end

		Wait(10000)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIM
-----------------------------------------------------------------------------------------------------------------------------------------
local inCarryAnim = ''
local inCarryDict = ''
local carryPartnerSid = nil

local function resetCarryState(notifyPartner)
    local ped = PlayerPedId()
    local sid = carryPartnerSid

    inCarry = false
    inCarryDict = ''
    inCarryAnim = ''
    carryPartnerSid = nil

    DetachEntity(ped, false, false)
    ClearPedTasks(ped)

    LocalPlayer.state.beingCarriyed = false
    LocalPlayer.state.animBlocked = false
    LocalPlayer.state.Buttons = false
    LocalPlayer.state.Cancel = false

    if notifyPartner and sid then
        vSERVER.syncRopeStop(sid)
    end
end


RegisterNetEvent('toggleRope')
AddEventHandler('toggleRope',function(pedTarget)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped) then return end

    if not inCarry then
        vSERVER.syncRopeCarry(pedTarget)
    else
        vSERVER.syncRopeStop(carryPartnerSid or pedTarget)
        resetCarryState(false)
    end
end)


Creative.syncRopeTarget = function(target)
    if inCarry and carryPartnerSid and carryPartnerSid ~= target then
        resetCarryState(true) 
    end

    carryPartnerSid = target

    local anim = {'pcarryzt2@animations','pcarryzt2clip'}
    local ped = PlayerPedId()
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

    if spin == nil then spin = 180.0 end
    if controlFlag == nil then controlFlag = 0 end

    if targetPed ~= 0 then
        AttachEntityToEntity(
            ped, targetPed, GetPedBoneIndex(targetPed, 24818),
            -0.330, 0.000, -0.040, 0.000, 0.000, -80.000,
            false, false, false, true, 1, true
        )
    end

    LocalPlayer.state.beingCarriyed = true
    LocalPlayer.state.animBlocked   = true
    LocalPlayer.state.Buttons       = true
    LocalPlayer.state.Cancel        = true

    if LoadAnim(anim[1]) then
        ClearPedTasks(ped)
        Wait(200)
        TaskPlayAnim(ped, anim[1], anim[2], 8.0, -8.0, -1, 1, false, false, false)
    end

    inCarryDict = anim[1]
    inCarryAnim = anim[2]
    inCarry = true
    setCarryTask()
end


Creative.syncRopeSource = function(target)
    if inCarry and carryPartnerSid and carryPartnerSid ~= target then
        resetCarryState(true) 
    end

    carryPartnerSid = target

    local anim = {'pcarryzt1@animations','pcarryzt1clip'}
    local ped = PlayerPedId()
    if controlFlag == nil then controlFlag = 0 end

    if LoadAnim(anim[1]) then
        TaskPlayAnim(ped, anim[1], anim[2], 8.0, -8.0, -1, 49, 0, 0, 0, 0)
    end

    inCarryDict = anim[1]
    inCarryAnim = anim[2]
    inCarry = true
    setCarryTask()
end


Creative.syncStopRope = function()
    resetCarryState(false) 
end

setCarryTask = function()
    CreateThread(function()
        while inCarry do
            local ped = PlayerPedId()

            if IsPedInAnyVehicle(ped, false) then
                resetCarryState(true)
                break
            end

            local partnerPid, partnerPed = -1, 0
            if carryPartnerSid then
                partnerPid = GetPlayerFromServerId(carryPartnerSid)
                if partnerPid ~= -1 then
                    partnerPed = GetPlayerPed(partnerPid)
                end
            end

            if partnerPid == -1 or partnerPed == 0 then
                resetCarryState(false)
                break
            end

            if inCarry then
                if not IsPedInAnyVehicle(ped, false) and inCarryDict ~= '' then
                    if not IsEntityAttachedToEntity(ped, partnerPed) then
                        resetCarryState(false)
                        break
                    end
                end

                if IsEntityAttached(ped) then

                else
                    if not IsEntityAttachedToEntity(partnerPed, ped) then
                        resetCarryState(false)
                        break
                    end
                end
            end

            if not IsPedInAnyVehicle(ped, false) and inCarryDict ~= '' and inCarryAnim ~= '' then
                if not IsEntityPlayingAnim(ped, inCarryDict, inCarryAnim, 3) then
                    if LoadAnim(inCarryDict, inCarryAnim) then
                        ClearPedTasks(ped)
                        Wait(200)
                        TaskPlayAnim(ped, inCarryDict, inCarryAnim, 5.0, 5.0, -1, 49, 0, 0, 0, 0)
                    end
                end
            end

            Wait(0)
        end
    end)
end

--fuel


local refuelActive = false
local dict, anim = "timetable@gardener@filling_can", "gar_ig_5_filling_can"

local JC_MODEL = `w_am_jerrycan`
local gallonProp = nil

local OFF   = { x = 0.18, y = 0.02, z = -0.06, rx = -95.0, ry = -15.0, rz = 15.0 }
local OFF_F = { x = 0.20, y = 0.02, z = -0.06, rx = -100.0, ry = -12.0, rz = 18.0 }

local function loadAnimDict(d)
    if not HasAnimDictLoaded(d) then
        RequestAnimDict(d)
        local t = GetGameTimer() + 5000
        while not HasAnimDictLoaded(d) and GetGameTimer() < t do Wait(0) end
    end
    return HasAnimDictLoaded(d)
end

local function loadModel(hash)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        local t = GetGameTimer() + 5000
        while not HasModelLoaded(hash) and GetGameTimer() < t do Wait(0) end
    end
    return HasModelLoaded(hash)
end

local function destroyJerrycanProp()
    if gallonProp and DoesEntityExist(gallonProp) then
        DetachEntity(gallonProp, true, true)
        DeleteEntity(gallonProp)
    end
    gallonProp = nil
end

local function chooseOffsetsForPed(ped)
    local mdl = GetEntityModel(ped)
    if mdl == GetHashKey("mp_f_freemode_01") then return OFF_F end
    return OFF
end

local function ensureJerrycanProp(ped)
    if gallonProp and DoesEntityExist(gallonProp) then return end
    local mdl = JC_MODEL
    if not loadModel(mdl) then mdl = `prop_ld_jerrycan_01`; loadModel(mdl) end
    local px, py, pz = table.unpack(GetEntityCoords(ped, true))
    gallonProp = CreateObjectNoOffset(mdl, px, py, pz + 0.2, false, false, false)
    if not gallonProp or not DoesEntityExist(gallonProp) then
        mdl = `prop_ld_jerrycan_01`; loadModel(mdl)
        gallonProp = CreateObjectNoOffset(mdl, px, py, pz + 0.2, false, false, false)
        if not gallonProp or not DoesEntityExist(gallonProp) then return end
    end
    SetEntityCollision(gallonProp, false, false)
    SetEntityCompletelyDisableCollision(gallonProp, true, true)
    SetEntityAsMissionEntity(gallonProp, true, true)
    local bone = GetPedBoneIndex(ped, 28422)
    if bone == -1 then bone = GetPedBoneIndex(ped, 57005) end
    local O = chooseOffsetsForPed(ped)
    AttachEntityToEntity(gallonProp, ped, bone, O.x, O.y, O.z, O.rx, O.ry, O.rz, true, true, false, true, 1, true)
end

RegisterNetEvent("hype-fuel:startCanAnim")
AddEventHandler("hype-fuel:startCanAnim", function(useProp)
    if refuelActive then return end
    refuelActive = true

    local ped = PlayerPedId()
    ClearPedSecondaryTask(ped)

    if loadAnimDict(dict) then
        if useProp == nil then useProp = true end
        if useProp then ensureJerrycanProp(ped) else destroyJerrycanProp() end

        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        TaskPlayAnim(ped, dict, anim, 8.0, 8.0, -1, 51, 0.0, false, false, false)

        CreateThread(function()
            local nextReplay = 0
            while refuelActive do
                ped = PlayerPedId()
                if useProp then ensureJerrycanProp(ped) end

                DisableControlAction(0, 18, true)
                DisableControlAction(0, 21, true) -- sprint
                DisableControlAction(0, 22, true)
                DisableControlAction(0, 23, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 30, true)
                DisableControlAction(0, 31, true)
                DisableControlAction(0, 57, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 143, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 263, true)

                if not IsEntityPlayingAnim(ped, dict, anim, 3) and GetGameTimer() >= nextReplay then
                    TaskPlayAnim(ped, dict, anim, 2.0, 2.0, -1, 51, 0.0, false, false, false)
                    nextReplay = GetGameTimer() + 500
                end

                if IsPedInAnyVehicle(ped) or IsPedRagdoll(ped) or IsEntityDead(ped) then
                    refuelActive = false
                end

                Wait(0)
            end

            if IsEntityPlayingAnim(ped, dict, anim, 3) then
                StopAnimTask(ped, dict, anim, 1.0)
            end
            destroyJerrycanProp()
			vRP.Destroy()
            RemoveAnimDict(dict)
        end)
    else
        refuelActive = false
        destroyJerrycanProp()
		vRP.Destroy()
    end
end)


RegisterNetEvent("hype-fuel:stopCanAnim")
AddEventHandler("hype-fuel:stopCanAnim", function()
    refuelActive = false
    destroyJerrycanProp()
	vRP.Destroy()
end)

