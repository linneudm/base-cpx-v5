if Config.Framework ~= "standalone" then
    return
end

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

function parseVehicle(vehicle)
    return {
        model = vehicle.Vehicle,
        plate = vehicle.Plate,
    }
end

function GetPlayerVehicles(source)
    local Passport = vRP.Passport(source)
    local vehicles = vRP.Query("vehicles/UserVehicles", { Passport = Passport })
    local parsedVehicles = {}
    for i = 1, #vehicles do
        parsedVehicles[i] = parseVehicle(vehicles[i])
    end
    return parsedVehicles
end

function GetVehicle(source, plate)
    return nil
end
