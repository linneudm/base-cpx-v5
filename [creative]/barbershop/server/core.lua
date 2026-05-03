-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("barbershop", cRP)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECK
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.checkShares()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getFines(user_id) > 0 then
			TriggerClientEvent("Notify", source, "amarelo", "Multas pendentes encontradas.", 3000)
			return false
		end

		if exports["hud"]:Repose(user_id) or exports["hud"]:Wanted(user_id, source) then
			return false
		end

		return true
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.Update(Table, Creation)
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		vRP.Query("playerdata/SetData", { Passport = Passport, Name = "Barbershop", Information = json.encode(Table) })

		if Creation then
			vRP.Query("playerdata/SetData", { Passport = Passport, Name = "Creator", Information = json.encode(1) })
			exports["vrp"]:Bucket(source, "Exit")
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- MODE
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.Mode()
	local Return = false
	local source = source
	local Passport = vRP.getUserId(source)
	if Passport then
		local Identity = vRP.userIdentity(Passport)
		if Identity and Identity["id"] > 0 then
			Return = true
		end
	end

	return Return
end
