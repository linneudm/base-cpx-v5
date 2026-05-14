-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Flags = 0
local Dict = nil
local Name = nil
local Active = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYANIM
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.playAnim(Upper, Sequency, Loop)
	local Ped = PlayerPedId()
	local DictName = Sequency[1] or Sequency["1"] or Sequency.dict or Sequency.Dict
	local AnimName = Sequency[2] or Sequency["2"] or Sequency.anim or Sequency.Anim
	if not Sequency["task"] and (not DictName or not AnimName) then
		return false
	end

	if Sequency["task"] then
		tvRP.StopAnim(true)

		if Sequency["task"] == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then
			local Coords = GetEntityCoords(Ped)
			local Heading = GetEntityHeading(Ped)
			TaskStartScenarioAtPosition(Ped, Sequency["task"], Coords["x"], Coords["y"], Coords["z"] - 1, Heading, 0, 0, false)
		else
			TaskStartScenarioInPlace(Ped, Sequency["task"], 0, false)
		end
	else
		Flags = 0
		tvRP.StopAnim(Upper)

		if LoadAnim(DictName) then
			if Upper then
				Flags = Flags + 48
			end

			if Loop then
				Flags = Flags + 1
			end

			Dict = DictName
			Name = AnimName

			if Flags == 49 then
				Active = true
			end

			TaskPlayAnim(Ped, DictName, AnimName, 8.0, 8.0, -1, Flags, 0, 0, 0, 0)
		end
	end
end

tvRP.PlayAnim = tvRP.playAnim

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADANIM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped = PlayerPedId()
		if Active and GetEntityHealth(Ped) > 100 then
			TimeDistance = 1

			local Ped = PlayerPedId()
			if not IsEntityPlayingAnim(Ped, Dict, Name, 3) then
				TaskPlayAnim(Ped, Dict, Name, 8.0, 8.0, -1, Flags, 1, 0, 0, 0)
			end

			DisableControlAction(0, 18, true)
			DisableControlAction(0, 24, true)
			DisableControlAction(0, 25, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 143, true)
			DisablePlayerFiring(Ped, true)
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOPANIM
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.StopAnim(Upper)
	Active = false
	local Ped = PlayerPedId()

	if Upper then
		ClearPedSecondaryTask(Ped)
	else
		ClearPedTasks(Ped)
	end
end

tvRP.stopAnim = tvRP.StopAnim

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMACTIVE
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.AnimActive()
	Active = false
end

tvRP.animActive = tvRP.AnimActive
