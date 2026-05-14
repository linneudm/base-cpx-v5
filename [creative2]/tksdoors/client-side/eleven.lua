local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

local doorslist = {}

CreateThread(function()
    TriggerServerEvent("tksDoors:requestSync")
end)

RegisterNetEvent("tksDoors:syncDoors")
AddEventHandler("tksDoors:syncDoors", function(dList)
    doorslist = dList
end)

RegisterNetEvent("tksDoors:updateLock")
AddEventHandler("tksDoors:updateLock", function(doorId, locked)
    if doorslist[doorId] then
        doorslist[doorId].locked = locked
    end
end)

-- Main Loop
CreateThread(function()
    while true do
        local msec = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        for k, v in pairs(doorslist) do
            local distance = #(coords - vector3(v.x, v.y, v.z))
            if distance <= 15 then
                msec = 5
                
                local doorHash = type(v.hash) == "number" and v.hash or GetHashKey(v.hash)
                local doorEntity = GetClosestObjectOfType(v.x, v.y, v.z, 2.0, doorHash, false, false, false)
                
                if DoesEntityExist(doorEntity) then
                    -- Congela/Descongela com base no status (locked == 1)
                    FreezeEntityPosition(doorEntity, v.locked)
                    
                    if distance <= v.dist then
                        local lockStr = v.locked and "~r~Trancada" or "~g~Destrancada"
                        DrawText3D(v.x, v.y, v.z, "~w~[E] " .. lockStr)
                        
                        if IsControlJustPressed(1, 38) then -- E key
                            TriggerServerEvent("tksDoors:toggleLock", v.id)
                        end
                    end
                end
            end
        end
        Wait(msec)
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 80)
end

RegisterNetEvent("tksDoors:openUI")
AddEventHandler("tksDoors:openUI", function(dataDoors)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        doors = dataDoors
    })
end)

RegisterNUICallback("closeUI", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("deleteDoor", function(data, cb)
    if data and data.id then
        TriggerServerEvent("tksDoors:deleteDoor", data.id)
    end
    cb("ok")
end)

RegisterNUICallback("updatePerm", function(data, cb)
    if data and data.id and data.perm then
        TriggerServerEvent("tksDoors:updatePerm", data.id, data.perm)
    end
    cb("ok")
end)

RegisterNUICallback("teleport", function(data, cb)
    if data and data.x then
        local ped = PlayerPedId()
        SetEntityCoords(ped, data.x, data.y, data.z, false, false, false, false)
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "close" })
    end
    cb("ok")
end)

local creatingDoor = false
local selectedDoorData = nil
local candidateSecondDoor = nil

RegisterNUICallback("createDoor", function(data, cb)
    local perm = data.perm and data.perm ~= "" and data.perm or "Admin"
    local isGate = data.isGate and 1 or 0
    
    if selectedDoorData then
        -- Envia a porta principal
        TriggerServerEvent("tksDoors:addDoor", selectedDoorData.hash, selectedDoorData.x, selectedDoorData.y, selectedDoorData.z, perm, isGate)
        
        -- Se o usuário selecionou 'Dupla' e nós achamos a porta vizinha na mira
        if data.isDouble and candidateSecondDoor then
            -- Manda registrar a segunda porta vizinha com a mesma permissão, logo em seguida
            Wait(50)
            TriggerServerEvent("tksDoors:addDoor", candidateSecondDoor.hash, candidateSecondDoor.x, candidateSecondDoor.y, candidateSecondDoor.z, perm, isGate)
        end
        
        selectedDoorData = nil
        candidateSecondDoor = nil
    end
    
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("startCreateMode", function(data, cb)
    ExecuteCommand(Config.PanelCommand or "painelportas") -- Fecha UI do painel
    creatingDoor = true
    Config.NotifyClient("aviso", "Modo de criação ATIVADO. Aponte para a porta desejada e aperte [E].")
    startDoorCreationLoop()
    cb("ok")
end)

local function DrawEntityBoundingBox(entity, r, g, b, a)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local pad = 0.02
    min = min - vector3(pad, pad, pad)
    max = max + vector3(pad, pad, pad)
    
    local c1 = GetOffsetFromEntityInWorldCoords(entity, min.x, min.y, min.z)
    local c2 = GetOffsetFromEntityInWorldCoords(entity, max.x, min.y, min.z)
    local c3 = GetOffsetFromEntityInWorldCoords(entity, max.x, max.y, min.z)
    local c4 = GetOffsetFromEntityInWorldCoords(entity, min.x, max.y, min.z)
    
    local c5 = GetOffsetFromEntityInWorldCoords(entity, min.x, min.y, max.z)
    local c6 = GetOffsetFromEntityInWorldCoords(entity, max.x, min.y, max.z)
    local c7 = GetOffsetFromEntityInWorldCoords(entity, max.x, max.y, max.z)
    local c8 = GetOffsetFromEntityInWorldCoords(entity, min.x, max.y, max.z)
    
    DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, r, g, b, a)
    DrawLine(c2.x, c2.y, c2.z, c3.x, c3.y, c3.z, r, g, b, a)
    DrawLine(c3.x, c3.y, c3.z, c4.x, c4.y, c4.z, r, g, b, a)
    DrawLine(c4.x, c4.y, c4.z, c1.x, c1.y, c1.z, r, g, b, a)
    
    DrawLine(c5.x, c5.y, c5.z, c6.x, c6.y, c6.z, r, g, b, a)
    DrawLine(c6.x, c6.y, c6.z, c7.x, c7.y, c7.z, r, g, b, a)
    DrawLine(c7.x, c7.y, c7.z, c8.x, c8.y, c8.z, r, g, b, a)
    DrawLine(c8.x, c8.y, c8.z, c5.x, c5.y, c5.z, r, g, b, a)
    
    DrawLine(c1.x, c1.y, c1.z, c5.x, c5.y, c5.z, r, g, b, a)
    DrawLine(c2.x, c2.y, c2.z, c6.x, c6.y, c6.z, r, g, b, a)
    DrawLine(c3.x, c3.y, c3.z, c7.x, c7.y, c7.z, r, g, b, a)
    DrawLine(c4.x, c4.y, c4.z, c8.x, c8.y, c8.z, r, g, b, a)
end

function startDoorCreationLoop()
    CreateThread(function()
        while creatingDoor do
            Wait(0)
            local ped = PlayerPedId()
            local camCoord = GetGameplayCamCoord()
            local camRot = GetGameplayCamRot(2)
            
            local tZ = camRot.z * 0.0174532924
            local tX = camRot.x * 0.0174532924
            local num = math.abs(math.cos(tX))
            
            local forward = vector3(-math.sin(tZ) * num, math.cos(tZ) * num, math.sin(tX))
            local endCoords = camCoord + forward * 10.0
            
            local rayHandle = CastRayPointToPoint(camCoord.x, camCoord.y, camCoord.z, endCoords.x, endCoords.y, endCoords.z, 16, ped, 0)
            local _, hit, hitCoords, surfaceNormal, entityHit = GetRaycastResult(rayHandle)
            
            if hit == 1 and entityHit ~= 0 and GetEntityType(entityHit) == 3 then
                -- Calcula o centro REAL da entidade (ao inves da dobradica que eh a origin default de portas no GTA)
                local min, max = GetModelDimensions(GetEntityModel(entityHit))
                local center = (min + max) * 0.5
                local trueCenter = GetOffsetFromEntityInWorldCoords(entityHit, center.x, center.y, center.z)
                
                -- Renderiza a bolinha direcional vermelha no centro verdadeiro da porta
                DrawMarker(28, trueCenter.x, trueCenter.y, trueCenter.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 255, 0, 0, 200, false, false, 2, false, nil, nil, false)
                
                -- Desenha as linhas 3D exatas dos contornos da porta (Wireframe verde)
                DrawEntityBoundingBox(entityHit, 0, 255, 0, 255)
                
                if IsControlJustPressed(0, 38) or IsControlJustPressed(0, 24) then
                    local doorHash = GetEntityModel(entityHit)
                    local doorCoords = GetEntityCoords(entityHit)
                    
                    selectedDoorData = {
                        hash = doorHash,
                        x = doorCoords.x,
                        y = doorCoords.y,
                        z = doorCoords.z
                    }
                    
                    creatingDoor = false
                    
                    -- Verifica se existe uma SEGUNDA porta muito próxima (pra sugerir Porta Dupla no Painel)
                    local secondDoorFound = false
                    local handle, object = FindFirstObject()
                    local b = true
                    while b do
                        if object ~= ped and object ~= entityHit then
                            local objCoords = GetEntityCoords(object)
                            if #(doorCoords - objCoords) < 3.5 then
                                if GetEntityType(object) == 3 then -- Outro objeto perto
                                    candidateSecondDoor = {
                                        hash = GetEntityModel(object),
                                        x = objCoords.x,
                                        y = objCoords.y,
                                        z = objCoords.z
                                    }
                                    secondDoorFound = true
                                    break
                                end
                            end
                        end
                        b, object = FindNextObject(handle)
                    end
                    EndFindObject(handle)
                    
                    SetNuiFocus(true, true)
                    SendNUIMessage({ 
                        action = "openCreateModal",
                        hasDouble = secondDoorFound 
                    })
                end
            end
        end
    end)
end

-- Comando Administrativo para Criar Porta
RegisterCommand(Config.AddCommand, function(source, args, rawCommand)
    creatingDoor = not creatingDoor
    if creatingDoor then
        Config.NotifyClient("sucesso", "Modo de criação de portas HABILITADO. Aponte e use o botão de ação [E].")
        startDoorCreationLoop()
    else
        Config.NotifyClient("aviso", "Modo de criação DESLIGADO.")
    end
end)