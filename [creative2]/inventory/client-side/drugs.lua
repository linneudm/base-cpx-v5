-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Timer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- COCAINE
-----------------------------------------------------------------------------------------------------------------------------------------
local Cocaine = 0
local CocaineTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- Energetic
-----------------------------------------------------------------------------------------------------------------------------------------
local Energetic = 0
local EnergeticTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPEEDBOOST 
-----------------------------------------------------------------------------------------------------------------------------------------
local SpeedBoost = 0
local SpeedBoostTimer = 0
local SpeedBoostPower = 1.25
local SpeedBoostClipApplied = false

local function LoadClipset(name)
	RequestAnimSet(name)
	while not HasAnimSetLoaded(name) do
		Wait(0)
		RequestAnimSet(name)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- METHAMPHETAMINE
-----------------------------------------------------------------------------------------------------------------------------------------
local Methamphetamine = 0
local MethamphetamineTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- METADONE
-----------------------------------------------------------------------------------------------------------------------------------------
local Metadone = 0
local MetadoneTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- HEROIN
-----------------------------------------------------------------------------------------------------------------------------------------
local Heroin = 0
local HeroinTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRACK
-----------------------------------------------------------------------------------------------------------------------------------------
local Crack = 0
local CrackTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- JOINT
-----------------------------------------------------------------------------------------------------------------------------------------
local Joint = 0
local JointTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- OXYCONTIN
-----------------------------------------------------------------------------------------------------------------------------------------
local Oxycontin = 0
local OxycontinTimer = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped = PlayerPedId()

		if not IsPedInAnyVehicle(Ped) then
			local Entitys = ClosestPed(2)
			local Progress = GetGameTimer()

			if Entitys and not Entity(Entitys)["state"]["Drugs"] then
				TimeDistance = 1

				if IsControlJustPressed(1,38) and GetGameTimer() >= Timer and GetVehiclePedIsIn(Entitys,true) == 0 then
					local TimeDrugs = vSERVER.CheckDrugs()
					if TimeDrugs then
						TriggerEvent("Progress","Vendendo",TimeDrugs * 1000)
						Progress = GetGameTimer() + (TimeDrugs * 1000)
						Timer = GetGameTimer() + 5000

						if not NetworkHasControlOfEntity(Entitys) then
							NetworkRequestControlOfEntity(Entitys)
							local tries = 0
							while not NetworkHasControlOfEntity(Entitys) and tries < 200 do
								NetworkRequestControlOfEntity(Entitys)
								Wait(0)
								tries = tries + 1
							end
						end

						ClearPedTasks(Entitys)
						ClearPedSecondaryTask(Entitys)
						ClearPedTasksImmediately(Entitys)

						TaskSetBlockingOfNonTemporaryEvents(Entitys,true)
						SetBlockingOfNonTemporaryEvents(Entitys,true)
						SetEntityAsMissionEntity(Entitys,true,true)
						SetPedDropsWeaponsWhenDead(Entitys,false)
						SetPedSuffersCriticalHits(Entitys,false)
						TaskTurnPedToFaceEntity(Entitys,Ped,0.0)

						LocalPlayer["state"]:set("Buttons",true,true)
						LocalPlayer["state"]:set("Commands",true,true)
						Entity(Entitys)["state"]:set("Drugs",true,true)

						SetTimeout(1000,function()
							if LoadAnim("jh_1_ig_3-2") then
								TaskPlayAnim(Entitys,"jh_1_ig_3-2","cs_jewelass_dual-2",8.0,8.0,-1,49,0,0,0,0)
							end
						end)

						while true do
							local Ped = PlayerPedId()
							local Coords = GetEntityCoords(Ped)
							local EntityCoords = GetEntityCoords(Entitys)

							if #(Coords - EntityCoords) <= 2 then
								if Progress <= GetGameTimer() and LoadModel("prop_anim_cash_note") then
									local Object = CreateObjectNoOffset("prop_anim_cash_note",Coords["x"],Coords["y"],Coords["z"],false,false,false)
									AttachEntityToEntity(Object,Entitys,GetPedBoneIndex(Entitys,28422),0.0,0.0,0.0,90.0,0.0,0.0,true,true,false,true,2,true)
									vRP.CreateObjects("mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422,0.0,-0.05,0.05,180.0,0.0,0.0)
									SetModelAsNoLongerNeeded("prop_anim_cash_note")
									ClearPedSecondaryTask(Entitys)
									ClearPedTasks(Entitys)

									if LoadAnim("mp_safehouselost@") then
										TaskPlayAnim(Entitys,"mp_safehouselost@","package_dropoff",8.0,8.0,-1,16,0,0,0,0)
									end

									Wait(3000)

									if DoesEntityExist(Object) then
										DeleteEntity(Object)
									end

									LocalPlayer["state"]:set("Buttons",false,true)
									LocalPlayer["state"]:set("Commands",false,true)
									TaskWanderStandard(Entitys,10.0,10)
									SetEntityAsNoLongerNeeded(Entitys)
									vSERVER.PaymentDrugs()
									vRP.Destroy()

									break
								end
							else
								LocalPlayer["state"]:set("Buttons",false,true)
								LocalPlayer["state"]:set("Commands",false,true)
								TriggerEvent("Progress","Cancelando",1000)
								TaskWanderStandard(Entitys,10.0,10)
								SetEntityAsNoLongerNeeded(Entitys)
								ClearPedSecondaryTask(Entitys)
								ClearPedTasks(Entitys)

								break
							end

							Wait(1)
						end
					end
				end
			end
		end

		Wait(TimeDistance)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESTPED
-----------------------------------------------------------------------------------------------------------------------------------------
function ClosestPed(Radius)
	local Selected = false
	local Ped = PlayerPedId()
	local Radius = Radius + 0.0001
	local Coords = GetEntityCoords(Ped)
	local GamePool = GetGamePool("CPed")

	for _,Entity in pairs(GamePool) do
		if Entity ~= Ped
			and not IsPedAPlayer(Entity)
			and not IsEntityDead(Entity)
			and not IsPedDeadOrDying(Entity,true)
			and not IsPedInAnyVehicle(Entity)
			and GetPedType(Entity) ~= 28
			and not DecorGetBool(Entity,"CREATIVE_PED")
		then
			if NetworkGetEntityIsNetworked(Entity) or not Selected then
				local EntityCoords = GetEntityCoords(Entity)
				local EntityDistance = #(Coords - EntityCoords)
				if EntityDistance < Radius then
					Radius = EntityDistance
					Selected = Entity
				end
			end
		end
	end

	return Selected
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- COCAINE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Cocaine")
AddEventHandler("Cocaine",function()
	if AnimpostfxIsRunning("MinigameTransitionIn") then
		AnimpostfxStop("MinigameTransitionIn")
	end

	AnimpostfxPlay("MinigameTransitionIn",0,true)
	Cocaine = Cocaine + 30
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENERGETIC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Energetic")
AddEventHandler("Energetic",function(Timer,Number)
	Energetic = Energetic + Timer
	SetRunSprintMultiplierForPlayer(PlayerId(),Number)
	PlaySoundFrontend(-1,'RACE_PLACED','HUD_AWARDS',false)
	TriggerEvent('Notify','Aviso','Seu coração está acelerado!',"amarelo",5000)

	--[[ if not AnimpostfxIsRunning("HeistTripSkipFade") then
		AnimpostfxPlay("HeistTripSkipFade",0,true)
	end ]]
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- METHAMPHETAMINE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Methamphetamine")
AddEventHandler("Methamphetamine",function()
	if AnimpostfxIsRunning("Dont_tazeme_bro") then
		AnimpostfxStop("Dont_tazeme_bro")
	end

	AnimpostfxPlay("Dont_tazeme_bro",0,true)
	Methamphetamine = Methamphetamine + 30
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- METADONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Metadone")
AddEventHandler("Metadone",function()
	if AnimpostfxIsRunning("DeathFailMPDark") then
		AnimpostfxStop("DeathFailMPDark")
	end

	AnimpostfxPlay("DeathFailMPDark",90000,false)

	if not LocalPlayer["state"]["DamageModify"] then
		LocalPlayer["state"]:set("DamageModify",true,false)
	end

	SetPlayerMeleeWeaponDamageModifier(PlayerId(),1.1)
	SetPlayerWeaponDamageModifier(PlayerId(),1.1)
	SetAiMeleeWeaponDamageModifier(7.5)
	SetAiWeaponDamageModifier(0.75)
	Metadone = Metadone + 600
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HEROIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Heroin")
AddEventHandler("Heroin",function()
	if AnimpostfxIsRunning("DrugsMichaelAliensFight") then
		AnimpostfxStop("DrugsMichaelAliensFight")
	end

	TriggerEvent("Health")
	SetPedMaxHealth(PlayerPedId(),250)
	SetEntityMaxHealth(PlayerPedId(),250)
	AnimpostfxPlay("DrugsMichaelAliensFight",90000,false)

	Heroin = 900
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Crack")
AddEventHandler("Crack",function()
	if AnimpostfxIsRunning("HeistCelebPassBW") then
		AnimpostfxStop("HeistCelebPassBW")
	end

	AnimpostfxPlay("HeistCelebPassBW",300000,false)
	TriggerEvent("Hunger",90000)
	TriggerEvent("Thirst",90000)
	Crack = 600
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- JOINT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Joint")
AddEventHandler("Joint",function()
	if AnimpostfxIsRunning("DeathFailMPIn") then
		AnimpostfxStop("DeathFailMPIn")
	end

	AnimpostfxPlay("DeathFailMPIn",0,true)
	Joint = Joint + 30
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OXYCONTIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Oxycontin")
AddEventHandler("Oxycontin",function()
	if AnimpostfxIsRunning("DrugsMichaelAliensFight") then
		AnimpostfxStop("DrugsMichaelAliensFight")
	end
 
	AnimpostfxPlay("DrugsMichaelAliensFight",0,true)
	Oxycontin = 30
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPEEDBOOST 
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("SpeedBoost")
AddEventHandler("SpeedBoost",function(duration,power)
    local ped = PlayerPedId()
    PlaySoundFrontend(-1,'RACE_PLACED','HUD_AWARDS',false)
    TriggerEvent('Notify','Aviso','Seu coração está acelerado!',"amarelo",5000)


    -- if not AnimpostfxIsRunning("HeistTripSkipFade") then
    --     AnimpostfxPlay("HeistTripSkipFade", 0, true)
    -- end

    SpeedBoost = (SpeedBoost or 0) + math.floor(duration or 30)
    SpeedBoostPower = power or 1.25
    SpeedBoostTimer = GetGameTimer()

    SetPedConfigFlag(ped, 427, true)
    SetRunSprintMultiplierForPlayer(PlayerId(), SpeedBoostPower)
    SetPedMoveRateOverride(ped, SpeedBoostPower)
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADMETH 
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Pid = PlayerId()
		local Ped = PlayerPedId()
		local Health = GetEntityHealth(Ped)
		local waitTime = 1000

		if Cocaine > 0 and GetGameTimer() >= CocaineTimer then
			Cocaine = Cocaine - 1
			CocaineTimer = GetGameTimer() + 1000

			if Cocaine <= 0 or Health <= 100 then
				if AnimpostfxIsRunning("MinigameTransitionIn") then
					AnimpostfxStop("MinigameTransitionIn")
				end
				Cocaine = 0
			end
		end

		if Methamphetamine > 0 and GetGameTimer() >= MethamphetamineTimer then
			Methamphetamine = Methamphetamine - 1
			MethamphetamineTimer = GetGameTimer() + 1000

			if Methamphetamine <= 0 or Health <= 100 then
				if AnimpostfxIsRunning("Dont_tazeme_bro") then
					AnimpostfxStop("Dont_tazeme_bro")
				end
				Methamphetamine = 0
			end
		end

		if Metadone > 0 and GetGameTimer() >= MetadoneTimer then
			Metadone = Metadone - 1
			MetadoneTimer = GetGameTimer() + 1000

			if Metadone <= 0 or GetEntityHealth(Ped) <= 100 then
				if AnimpostfxIsRunning("DeathFailMPDark") then
					AnimpostfxStop("DeathFailMPDark")
				end

				Metadone = 0
				SetAiWeaponDamageModifier(0.5)
				SetAiMeleeWeaponDamageModifier(5.0)
				SetPlayerWeaponDamageModifier(Pid,1.0)
				SetPlayerMeleeWeaponDamageModifier(Pid,1.0)
				LocalPlayer["state"]:set("DamageModify",false,false)
			end
		end

		if Heroin > 0 and GetGameTimer() >= HeroinTimer then
			Heroin = Heroin - 1
			HeroinTimer = GetGameTimer() + 1000

			if Heroin <= 0 or Health <= 100 then
				if AnimpostfxIsRunning("DrugsMichaelAliensFight") then
					AnimpostfxStop("DrugsMichaelAliensFight")
				end

				if GetEntityHealth(Ped) > 200 then
					SetEntityHealth(Ped,200)
				end

				SetEntityMaxHealth(Ped,200)
				SetPedMaxHealth(Ped,200)
				TriggerEvent("Health")
				Heroin = 0
			end
		end

		if Crack > 0 and GetGameTimer() >= CrackTimer then
			Crack = Crack - 1
			CrackTimer = GetGameTimer() + 1000

			if Crack <= 0 or Health <= 100 then
				if AnimpostfxIsRunning("HeistCelebPassBW") then
					AnimpostfxStop("HeistCelebPassBW")
				end

				TriggerEvent("Hunger",180000)
				TriggerEvent("Thirst",180000)
				Crack = 0
			end
		end

		if Joint > 0 and GetGameTimer() >= JointTimer then
			Joint = Joint - 1
			JointTimer = GetGameTimer() + 1000

			if Joint <= 0 or GetEntityHealth(Ped) <= 100 then
				if AnimpostfxIsRunning("DeathFailMPIn") then
					AnimpostfxStop("DeathFailMPIn")
				end

				Joint = 0
			end
		end

		if Oxycontin > 0 and GetGameTimer() >= OxycontinTimer then
			Oxycontin = Oxycontin - 1
			OxycontinTimer = GetGameTimer() + 1000

			if Oxycontin <= 0 or Health <= 100 then
				if AnimpostfxIsRunning("DrugsMichaelAliensFight") then
					AnimpostfxStop("DrugsMichaelAliensFight")
				end

				Oxycontin = 0
			end
		end

		if Energetic > 0 and GetGameTimer() >= EnergeticTimer then
			Energetic = Energetic - 1
			RestorePlayerStamina(Pid,1.0)
			EnergeticTimer = GetGameTimer() + 2000

			if Energetic <= 0 or Health <= 100 then
				if AnimpostfxIsRunning("HeistTripSkipFade") then
					AnimpostfxStop("HeistTripSkipFade")
				end

				if Energetic <= 0 and Health > 100 then
					TriggerEvent("Notify","Aviso","O efeito do energético passou, seus batimentos cardíacos retornaram ao normal.","amarelo",7000)
				end

				if AnimpostfxIsRunning("MinigameTransitionIn") then
					AnimpostfxStop("MinigameTransitionIn")
				end

				

				SetRunSprintMultiplierForPlayer(Pid,1.0)
				SetPedMoveRateOverride(Ped,1.0)
				Energetic = 0
			end
		end

		if SpeedBoost > 0 and GetGameTimer() >= SpeedBoostTimer then
			SpeedBoost = SpeedBoost - 1
			SpeedBoostTimer = GetGameTimer() + 2000

			local inInterior = IsInteriorScene() or (GetInteriorFromEntity(Ped) ~= 0)
			RestorePlayerStamina(Pid,1.0)

			
			SetPedConfigFlag(Ped, 427, true) 

			if inInterior then
				--[[ if not SpeedBoostClipApplied then
					LoadClipset("move_m@quick")
					SetPedMovementClipset(Ped, "move_m@quick", 1.0)
					SpeedBoostClipApplied = true
				end ]]

				if IsControlPressed(0,32) or IsControlPressed(0,33) or IsControlPressed(0,34) or IsControlPressed(0,35) then
					SetPedDesiredMoveBlendRatio(Ped, 3.0)
				end

				SetPedMoveRateOverride(Ped, SpeedBoostPower)
				SetRunSprintMultiplierForPlayer(Pid, SpeedBoostPower)
				waitTime = 60
			else
				if SpeedBoostClipApplied then
					ResetPedMovementClipset(Ped, 0.25)
					SpeedBoostClipApplied = false
				end
				SetRunSprintMultiplierForPlayer(Pid, SpeedBoostPower)
				SetPedMoveRateOverride(Ped, SpeedBoostPower)
				waitTime = 100
			end

			if SpeedBoost <= 0 or Health <= 100 then
				
				if SpeedBoost <= 0 and Health > 100 then
					TriggerEvent("Notify","Aviso","O efeito do energético passou, seus batimentos cardíacos retornaram ao normal.","amarelo",7000)
				end

				SetPedConfigFlag(Ped, 427, false)
				SetPedMoveRateOverride(Ped, 1.0)
				SetRunSprintMultiplierForPlayer(Pid, 1.0)

				if SpeedBoostClipApplied then
					ResetPedMovementClipset(Ped, 0.25)
					SpeedBoostClipApplied = false
				end

				if AnimpostfxIsRunning("HeistTripSkipFade") then
					AnimpostfxStop("HeistTripSkipFade")
				end

				SpeedBoost = 0
			end
		end

		Wait(waitTime)
	end
end)
