local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local doors = {}

local function getUserId(source)
    if vRP.Passport then return vRP.Passport(source) end
    return vRP.getUserId(source)
end

local function hasPermission(user_id, perm)
    if not perm or perm == "" then return true end
    if vRP.HasPermission then return vRP.HasPermission(user_id, perm) end
    if vRP.hasPermission then return vRP.hasPermission(user_id, perm) end
    return false
end

CreateThread(function()
    Wait(1000)
    local createTableQuery = [[
        CREATE TABLE IF NOT EXISTS `tks_doors` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `hash` varchar(50) NOT NULL,
            `x` float NOT NULL,
            `y` float NOT NULL,
            `z` float NOT NULL,
            `isGate` tinyint(1) DEFAULT 0,
            `dist` float DEFAULT 2,
            `text` tinyint(1) DEFAULT 1,
            `locked` tinyint(1) DEFAULT 1,
            `perm` varchar(100) DEFAULT NULL,
            PRIMARY KEY (`id`)
        );
    ]]

    if vRP.Prepare then
        vRP.Prepare("tksDoors/create_table", createTableQuery)
        vRP.Prepare("tksDoors/get_doors", "SELECT * FROM tks_doors")
        vRP.Prepare("tksDoors/update_perm", "UPDATE tks_doors SET perm = @perm WHERE id = @id")
        vRP.Prepare("tksDoors/delete_door", "DELETE FROM tks_doors WHERE id = @id")
        vRP.Prepare("tksDoors/add_door",
            "INSERT INTO tks_doors(hash, x, y, z, isGate, dist, text, locked, perm) VALUES(@hash, @x, @y, @z, @isGate, @dist, @text, @locked, @perm)")
        vRP.Query("tksDoors/create_table", {})
    else
        vRP._prepare("tksDoors/create_table", createTableQuery)
        vRP._prepare("tksDoors/get_doors", "SELECT * FROM tks_doors")
        vRP._prepare("tksDoors/update_perm", "UPDATE tks_doors SET perm = @perm WHERE id = @id")
        vRP._prepare("tksDoors/delete_door", "DELETE FROM tks_doors WHERE id = @id")
        vRP._prepare("tksDoors/add_door",
            "INSERT INTO tks_doors(hash, x, y, z, isGate, dist, text, locked, perm) VALUES(@hash, @x, @y, @z, @isGate, @dist, @text, @locked, @perm)")
        if vRP.Query then vRP.Query("tksDoors/create_table", {}) end
    end

    Wait(500)
    loadDoorsFromDB()
end)

function loadDoorsFromDB()
    local res = {}
    if vRP.Query then
        print("vRP.query")
        res = vRP.Query("tksDoors/get_doors")
        print(json.encode(res))
    elseif vRP.Query then
        res = vRP.Query("tksDoors/get_doors")
    end

    if type(res) == "table" then
        for _, v in pairs(res) do
            doors[v.id] = {
                id = v.id,
                hash = tonumber(v.hash) or v.hash,
                x = v.x,
                y = v.y,
                z = v.z,
                isGate = v.isGate == 1 or v.isGate == true,
                dist = v.dist,
                text = v.text == 1 or v.text == true,
                locked = v.locked == 1 or v.locked == true,
                perm = v.perm
            }
        end
        print("[tksDoors] Carregadas " .. tostring(#res) .. " portas do banco de dados.")
    end
end

-- Sync com novos jogadores entrando
RegisterNetEvent("tksDoors:requestSync")
AddEventHandler("tksDoors:requestSync", function()
    TriggerClientEvent("tksDoors:syncDoors", source, doors)
end)

-- Sistema de Trancar / Destrancar porta
RegisterNetEvent("tksDoors:toggleLock")
AddEventHandler("tksDoors:toggleLock", function(doorId)
    local source = source
    local user_id = getUserId(source)
    if user_id then
        local door = doors[doorId]
        if door then
            if hasPermission(user_id, door.perm) then
                door.locked = not door.locked
                TriggerClientEvent("tksDoors:updateLock", -1, doorId, door.locked)
                -- Notificacao de trancar poderia ir aqui
            end
        end
    end
end)

-- Abertura do Menu Adiministrador (NUI)
-- Abertura do Menu Adiministrador (NUI)
RegisterCommand(Config.PanelCommand, function(source, args, rawCommand)
    local user_id = getUserId(source)
    if user_id then
        if hasPermission(user_id, Config.Permission) or true then
            local doorArray = {}
            for k, v in pairs(doors) do
                table.insert(doorArray, v)
            end

            TriggerClientEvent("tksDoors:openUI", source, doorArray)
        end
    end
end)

-- NUI Callbacks
RegisterNetEvent("tksDoors:deleteDoor")
AddEventHandler("tksDoors:deleteDoor", function(id)
    local source = source
    local user_id = getUserId(source)
    if user_id and hasPermission(user_id, Config.Permission) then
        local doorId = tonumber(id)
        if doors[doorId] then
            doors[doorId] = nil
            if vRP.Query then vRP.Query("tksDoors/delete_door", { id = doorId }) end
            TriggerClientEvent("tksDoors:syncDoors", -1, doors)
        end
    end
end)

RegisterNetEvent("tksDoors:updatePerm")
AddEventHandler("tksDoors:updatePerm", function(id, perm)
    local source = source
    local user_id = getUserId(source)
    if user_id and hasPermission(user_id, Config.Permission) then
        local doorId = tonumber(id)
        if doors[doorId] then
            doors[doorId].perm = perm
            if vRP.Query then vRP.Query("tksDoors/update_perm", { id = doorId, perm = perm }) end
            TriggerClientEvent("tksDoors:syncDoors", -1, doors)
        end
    end
end)

RegisterNetEvent("tksDoors:addDoor")
AddEventHandler("tksDoors:addDoor", function(hash, x, y, z, perm)
    local source = source
    local user_id = getUserId(source)
    if user_id and hasPermission(user_id, Config.Permission) then
        if vRP.Query then
            vRP.Query("tksDoors/add_door", {
                hash = tostring(hash),
                x = x,
                y = y,
                z = z,
                isGate = 0,
                dist = 2.0,
                text = 1,
                locked = 1,
                perm = perm
            })
        end

        SetTimeout(500, function()
            loadDoorsFromDB()
            TriggerClientEvent("tksDoors:syncDoors", -1, doors)
            Config.Notify(source, "sucesso", "A porta (" .. hash .. ") foi adicionada à sua database com sucesso.")
        end)
    end
end)

-- Comando Administrativo para forçar recarregamento das portas do banco de dados
RegisterCommand(Config.ReloadCommand, function(source, args, rawCommand)
    local user_id = getUserId(source)
    if user_id then
        if hasPermission(user_id, Config.Permission) then
            -- Limpa o cache local
            doors = {}
            -- Carrega do banco de novo
            loadDoorsFromDB()
            -- Força sync para todo mundo que tá online na cidade
            TriggerClientEvent("tksDoors:syncDoors", -1, doors)

            Config.Notify(source, "sucesso", "A tabela de portas foi RECARREGADA e sincronizada com sucesso!")
        end
    end
end)
