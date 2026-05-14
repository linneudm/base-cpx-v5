-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Name = nil
local Amounts = 1
local Selected = 1
local Active = false
local Experience = 1
local Vehicle = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- PEDS
-----------------------------------------------------------------------------------------------------------------------------------------
local Peds = {
	"g_m_y_mexgang_01","g_m_y_lost_01","u_m_o_finguru_01","g_m_y_salvagoon_01","g_f_y_lost_01","a_m_y_business_02","s_m_m_postal_01",
	"g_m_y_korlieut_01","s_m_m_trucker_01","g_m_m_armboss_01","mp_m_shopkeep_01","ig_dale","u_m_y_baygor","cs_gurk","ig_casey",
	"s_m_y_garbage","a_m_o_ktown_01","a_f_y_eastsa_03"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
local Weapons = {
	"WEAPON_PISTOL",
	"WEAPON_SMG"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CATEGORY
-----------------------------------------------------------------------------------------------------------------------------------------
local Category = {
	[1] = {
		"gt500","toros","sheava","surano","rapidgt","feltzer2","alpha","gp1",
		"infernus","bullet","freecrawler","turismo2","zr350",
		"locust","seven70","caracara2","ruffian","enduro"
	},
	[2] = {
		"specter","rebla","ruston","jester","banshee","cypher","voltic",
		"rt3000","sc1","carbonizzare","infernus2","imorgon","sultan2",
		"elegy2","yosemite2","ninef","everon","double"
	},
	[3] = {
		"jackal","sugoi","penumbra","paragon","nero","komoda","ninef2",
		"futo","buffalo3","banshee2","adder","schlagen","bestiagts",
		"jester3","elegy","cheetah2","khamelion","sanchez","diablous2"
	},
	[4] = {
		"omnis","massacro","euros","cheetah","tyrus","kuruma","nero2",
		"ardent","sultan3","autarch","fmj","jester2","carbonrs","reever"
	},
	[5] = {
		"gb200","sultanrs","pariah","vacca","zentorno","t20","issi7",
		"penetrator","emerus","revolter","sentinel3","bati","bf400"
	},
	[6] = {
		"flashgt","dominator7","osiris","turismor","jester4",
		"pfister811","italigtb2","akuma"
	},
	[7] = {
		"penumbra2","tempesta","raiden","vectre","entityxf",
		"comet6","drafter","bati2"
	},
	[8] = {
		"reaper","growler","tigon","italigtb","visione",
		"entity2","deveste","hakuchou"
	},
	[9] = {
		"vagner","tyrant","krieger","furia","xa21",
		"neon","taipan","jugular","paragon2","hakuchou2"
	},
	[10] = {
		"calico","zorrusso","italirsx","coquette4",
		"italigto","cyclone","neo","shinobi","thrax"
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE
-----------------------------------------------------------------------------------------------------------------------------------------
local Dismantle = {
	vec4(-0.0,-0.0,0.0,0.0),
	vec4(0.0,-0.0,0.0,0.0)
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Dismantle()
	if not Active then
		Experience = vSERVER.Experience()
		local Level = ClassCategory(Experience)
		local RandLevels = math.random(Level)
		local Model = math.random(#Category[RandLevels])

		Selected = math.random(#Dismantle)
		Name = Category[RandLevels][Model]
		Active = true
		Amounts = 1

		if Level == 3 or Level == 4 then
			Amounts = 2
		elseif Level == 5 or Level == 6 then
			Amounts = 3
		elseif Level == 7 or Level == 8 then
			Amounts = 4
		elseif Level == 9 or Level == 10 then
			Amounts = 5
		end

		TriggerEvent("NotifyPush",{ code = 20, title = "Localização Veículo", x = Dismantle[Selected]["x"], y = Dismantle[Selected]["y"], z = Dismantle[Selected]["z"], color = 44 })

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE:RESET
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("dismantle:Reset")
AddEventHandler("dismantle:Reset",function()
	Name = nil
	Amounts = 1
	Selected = 1
	Active = false
	Vehicle = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADDISMANTLE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if Active and not Vehicle then
			local Ped = PlayerPedId()
			if #(GetEntityCoords(Ped) - Dismantle[Selected]["xyz"]) <= 75 then
				Vehicle = vSERVER.CreateVehicle(Name,Dismantle[Selected],Experience)

				SetTimeout(1000,function()
					local Network = NetToEnt(Vehicle)

					SetVehicleHasBeenOwnedByPlayer(Network,true)
					SetVehicleNeedsToBeHotwired(Network,false)
					DecorSetInt(Network,"Player_Vehicle",-1)
					SetVehRadioStation(Network,"OFF")

					SetVehicleModKit(Network,0)
					ToggleVehicleMod(Network,18,true)
					SetVehicleMod(Network,11,GetNumVehicleMods(Network,11) - 1,false)
					SetVehicleMod(Network,12,GetNumVehicleMods(Network,12) - 1,false)
					SetVehicleMod(Network,13,GetNumVehicleMods(Network,13) - 1,false)
					SetVehicleMod(Network,15,GetNumVehicleMods(Network,15) - 1,false)
				end)
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE:DISPATCH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("dismantle:Dispatch")
AddEventHandler("dismantle:Dispatch",function()
	local Ped = PlayerPedId()
	local Coords = GetEntityCoords(Ped)

	for Number = 1,Amounts do
		local FoundSafe = false
		local SpawnPosition = nil

		repeat
			local x = Coords.x + math.random(-25,25)
			local y = Coords.y + math.random(-25,25)
			local z = Coords.z

			local Hitz,Groundz = GetGroundZFor_3dCoord(x,y,z,true)
			local SafeHitz,SafeCoords = GetSafeCoordForPed(x,y,Groundz,false,16)

			if Hitz and SafeHitz and IsPointOnRoad(SafeCoords.x,SafeCoords.y,SafeCoords.z,0) then
				FoundSafe = true
				SpawnPosition = SafeCoords
			end
		until FoundSafe

		local Model = Peds[math.random(#Peds)]
		if FoundSafe and SpawnPosition and LoadModel(Model) then
			local Entitys = CreatePed(6,Model,SpawnPosition.x,SpawnPosition.y,SpawnPosition.z,0.0,true,false)

			SetPedArmour(Entitys,100)
			SetPedAccuracy(Entitys,95)
			SetPedMaxHealth(Entitys,500)
			SetEntityHealth(Entitys,500)

			SetPedCombatAttributes(Entitys,5,true)
			SetPedCombatAttributes(Entitys,0,false)
			SetPedCombatAttributes(Entitys,13,true)
			SetPedCombatAttributes(Entitys,25,true)
			SetPedCombatAttributes(Entitys,46,true)

			SetPedAlertness(Entitys,3)
			SetPedKeepTask(Entitys,true)
			SetPedCombatRange(Entitys,2)
			SetPedCombatAbility(Entitys,3)
			SetPedCombatMovement(Entitys,3)
			SetPedCanRagdoll(Entitys,false)
			SetPedSeeingRange(Entitys,150.0)
			SetPedHearingRange(Entitys,150.0)
			SetPedCanBeTargetted(Entitys,true)
			SetPedCanEvasiveDive(Entitys,true)
			SetPedTargetLossResponse(Entitys,1)
			SetPedFiringPattern(Entitys,-957453492)
			SetPedSuffersCriticalHits(Entitys,false)
			SetPedDropsWeaponsWhenDead(Entitys,false)
			SetBlockingOfNonTemporaryEvents(Entitys,true)
			SetPedRelationshipGroupHash(Entitys,696737330)
			SetPedRelationshipGroupHash(Entitys,-276063219)
			SetModelAsNoLongerNeeded(Model)

			local Rand = math.random(#Weapons)
			GiveWeaponToPed(Entitys,Weapons[Rand],250,false,true)
			SetCurrentPedWeapon(Entitys,Weapons[Rand],true)
			SetPedInfiniteAmmo(Entitys,true,Weapons[Rand])

			ClearPedTasksImmediately(Entitys)
			RegisterHatedTargetsAroundPed(Entitys,150.0)

			Citizen.CreateThread(function()
				while DoesEntityExist(Entitys) and not IsEntityDead(Entitys) do
					TaskCombatHatedTargetsAroundPed(Entitys,150.0,0)
					Wait(5000)
				end
			end)
		end
	end
end)