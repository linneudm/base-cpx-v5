-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("engine", cRP)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local vehFuels = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENTFUEL
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.paymentFuel(fuelPrice, vehPlate, vFuel)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local gasPrice = parseInt(fuelPrice)
		if gasPrice <= 0 then
			return true
		end

		local paid = false
		local walletData = vRP.getInventoryItemAmount(user_id, "dollars")
		local walletAmount = parseInt(walletData[1] or 0)
		local walletItem = walletData[2] ~= "" and walletData[2] or "dollars"
		if walletAmount >= gasPrice then
			paid = vRP.tryGetInventoryItem(user_id, walletItem, gasPrice, true)
		else
			local bank = vRP.getBank(user_id)
			if bank >= gasPrice then
				paid = vRP.paymentBank(user_id, gasPrice)
			end
		end

		if paid then
			local Players = vRPC.Players(source)
			for _, v in ipairs(Players) do
				async(function()
					TriggerClientEvent("engine:syncFuel", v, vehPlate, vFuel)
				end)
			end

			return true
		else
			TriggerClientEvent("Notify", source, "vermelho", "<b>Dólares</b> insuficientes para abastecer.", 5000)
			return false
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLEFUEL
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.vehicleFuel(vehPlate)
	if vehFuels[vehPlate] == nil and vehPlate ~= nil then
		vehFuels[vehPlate] = 50
	end

	return vehFuels[vehPlate]
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYFUEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("engine:tryFuel")
AddEventHandler("engine:tryFuel", function(vehPlate, vFuel)
	vehFuels[vehPlate] = vFuel
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETFUEL
-----------------------------------------------------------------------------------------------------------------------------------------
exports("engineFuel", function(vehPlate)
	if vehFuels[vehPlate] == nil then
		vehFuels[vehPlate] = 50
	end

	return vehFuels[vehPlate]
end)
