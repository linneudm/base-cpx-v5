if Config.Framework ~= "standalone" then
    return
end

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

function GetBalance(source)
    return vRP.GetBank(source)
end

function AddMoney(source, amount)
    return true
end

function AddMoneyOffline(identifier, amount)
    if amount <= 0 then
        return false
    end

    return true
end

function RemoveMoney(source, amount)
    return true
end
