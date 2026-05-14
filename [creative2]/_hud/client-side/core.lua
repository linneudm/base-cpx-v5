-- VRP Framework Setup
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPS = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")

-- Creative Interface (for external calls)
Creative = {}
Tunnel.bindInterface("hud", Creative)

-- Display States
Radar = false
Display = false
local isHoodActive = false
local gemstoneCount = 0
local isPauseMenuBlocking = false

-- Street Names
local currentRoadName = "Roads"
local currentCrossingName = "Crossing"

-- Request System
local requestActive = false
local requestAccepted = false
local requestTimeout = GetGameTimer()

-- Player Stats
local currentArmor = 0
local currentHealth = 200
local currentThirst = 100
local thirstDamageTimer = 0
local thirstDecayInterval = 120000
local thirstDecayTimer = GetGameTimer()

local currentHunger = 100
local hungerDamageTimer = 0
local hungerDecayInterval = 120000
local hungerDecayTimer = GetGameTimer()

local currentStress = 0
local stressEffectTimer = GetGameTimer()

local wantedTimer = 0
local wantedTimerStart = GetGameTimer()
local wantedLevel = 0

local reposeTimer = 0
local reposeTimerStart = GetGameTimer()
local reposeMaxTime = 0

local luckTimer = 0
local luckTimerStart = GetGameTimer()

local dexterityTimer = 0
local dexterityTimerStart = GetGameTimer()

-- Robberies Display Toggle
local robberiesVisible = false

RegisterCommand("esconderroubos", function()
    if robberiesVisible then
        robberiesVisible = false
        SendNUIMessage({ Action = "Robberies", Payload = false })
    else
        if GlobalState.Roubos then
            robberiesVisible = true
            SendNUIMessage({ Action = "Robberies", Payload = { true, GlobalState.Roubos } })
        end
    end
end)

AddStateBagChangeHandler("Roubos", nil, function(bagName, key, value)
    if value then
        SendNUIMessage({ Action = "Robberies", Payload = { true, value } })
        if not robberiesVisible then
            robberiesVisible = true
        end
    else
        SendNUIMessage({ Action = "Robberies", Payload = false })
        if robberiesVisible then
            robberiesVisible = false
        end
    end
end)

-- Coupon Display Toggle
local couponVisible = false

RegisterCommand("ToggleCoupon", function()
    if couponVisible then
        couponVisible = false
        SendNUIMessage({ Action = "Coupon", Payload = false })
    else
        if GlobalState.Cupom then
            couponVisible = true
            SendNUIMessage({ 
                Action = "Coupon", 
                Payload = { true, GlobalState.Cupom[1], GlobalState.Cupom[2], GlobalState.Cupom[3] } 
            })
        end
    end
end)

RegisterKeyMapping("ToggleCoupon", "Ativar/Desativar a visualização do cupom.", "keyboard", "F11")

AddStateBagChangeHandler("Cupom", nil, function(bagName, key, value)
    if value then
        SendNUIMessage({ 
            Action = "Coupon", 
            Payload = { true, value[1], value[2], value[3] } 
        })
        if not couponVisible then
            couponVisible = true
        end
    else
        SendNUIMessage({ Action = "Coupon", Payload = false })
        if couponVisible then
            couponVisible = false
        end
    end
end)

-- Initialize on Player Spawn
RegisterNetEvent("vRP:Active")
AddEventHandler("vRP:Active", function()
    if GlobalState.Cupom then
        SendNUIMessage({ 
            Action = "Coupon", 
            Payload = { true, GlobalState.Cupom[1], GlobalState.Cupom[2], GlobalState.Cupom[3] } 
        })
        couponVisible = true
    end
    
    if GlobalState.Roubos then
        SendNUIMessage({ Action = "Robberies", Payload = { true, GlobalState.Roubos } })
        robberiesVisible = true
    end
end)

-- Preload injured movement animation
function LoadMovement(animDict)
    RequestAnimSet(animDict)
    while not HasAnimSetLoaded(animDict) do
        Wait(10)
    end
end

-- Main HUD Loop
CreateThread(function()
    LoadMovement("move_m@injured")
    
    while true do
        if LocalPlayer.state.Active then
            local ped = PlayerPedId()
            
            if IsPauseMenuActive() then
                if not isPauseMenuBlocking and Display then
                    isPauseMenuBlocking = true
                    SendNUIMessage({ Action = "Body", Payload = false })
                end
            else
                if Display then
                    if isPauseMenuBlocking then
                        SendNUIMessage({ Action = "Body", Payload = true })
                        isPauseMenuBlocking = false
                    end
                    
                    local coords = GetEntityCoords(ped)
                    local armor = GetPedArmour(ped)
                    local health = GetEntityHealth(ped) - 100
                    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                    local streetName = GetStreetNameFromHashKey(streetHash)
                    local crossingName = GetStreetNameFromHashKey(crossingHash)
                    local maxHealth = GetEntityMaxHealth(ped)
                    
                    -- Health Management
                    if maxHealth ~= 200 then
                        local adjustedHealth = parseInt(health * 0.66)
                        if currentHealth ~= adjustedHealth then
                            health = adjustedHealth
                            if health > 100 then
                                health = 100
                            end
                            SendNUIMessage({ Action = "Health", Payload = health })
                            currentHealth = health
                        end
                    else
                        if health > 100 then
                            SetEntityHealth(ped, 200)
                            health = 100
                        end
                        
                        if currentHealth ~= health then
                            SendNUIMessage({ Action = "Health", Payload = health })
                            currentHealth = health
                        end
                        
                        -- Injured Movement
                        if not IsPedSwimming(ped) then
                            if health <= 30 then
                                if GetPedMovementClipset(ped) ~= -650503762 then
                                    LocalPlayer.state:set("Walk", false, false)
                                    SetPedMovementClipset(ped, "move_m@injured", 0.5)
                                end
                            elseif health > 30 then
                                if GetPedMovementClipset(ped) == -650503762 then
                                    LocalPlayer.state:set("Walk", false, false)
                                end
                            end
                            
                            SendNUIMessage({ Action = "Oxygen", Payload = false })
                        else
                            if IsPedSwimmingUnderWater(ped) then
                                local oxygenLevel = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
                                SendNUIMessage({ Action = "Oxygen", Payload = { true, oxygenLevel } })
                            else
                                SendNUIMessage({ Action = "Oxygen", Payload = false })
                            end
                        end
                    end
                    
                    -- Armor Update
                    if currentArmor ~= armor then
                        SendNUIMessage({ Action = "Armour", Payload = armor })
                        currentArmor = armor
                    end
                    
                    -- Street Names
                    if streetName ~= "" and currentRoadName ~= streetName then
                        SendNUIMessage({ Action = "Road", Payload = streetName })
                        currentRoadName = streetName
                    end
                    
                    if crossingName ~= "" and currentCrossingName ~= crossingName then
                        SendNUIMessage({ Action = "Crossing", Payload = crossingName })
                        currentCrossingName = crossingName
                    end
                    
                    -- Parachute Check
                    local hasParachute = HasPedGotWeapon(ped, GetHashKey("GADGET_PARACHUTE"), false)
                    SendNUIMessage({ Action = "Parachute", Payload = hasParachute })
                    
                    -- Clock Update
                    SendNUIMessage({ 
                        Action = "Clock", 
                        Payload = { GlobalState.Hours, GlobalState.Minutes } 
                    })
                end
            end
            
            -- Luck Timer
            if luckTimer > 0 then
                if luckTimerStart <= GetGameTimer() then
                    luckTimer = luckTimer - 1
                    luckTimerStart = GetGameTimer() + 1000
                    SendNUIMessage({ Action = "Luck", Payload = luckTimer })
                end
            end
            
            -- Dexterity Timer
            if dexterityTimer > 0 then
                if dexterityTimerStart <= GetGameTimer() then
                    dexterityTimer = dexterityTimer - 1
                    dexterityTimerStart = GetGameTimer() + 1000
                    SendNUIMessage({ Action = "Dexterity", Payload = dexterityTimer })
                end
            end
            
            -- Wanted Timer
            if wantedTimer > 0 then
                if wantedTimerStart <= GetGameTimer() then
                    wantedTimer = wantedTimer - 1
                    wantedTimerStart = GetGameTimer() + 1000
                    SendNUIMessage({ Action = "Wanted", Payload = { wantedTimer, wantedLevel } })
                end
            end
            
            -- Repose Timer
            if reposeTimer > 0 then
                if reposeTimerStart <= GetGameTimer() then
                    reposeTimer = reposeTimer - 1
                    reposeTimerStart = GetGameTimer() + 1000
                    SendNUIMessage({ Action = "Repose", Payload = { reposeTimer, reposeMaxTime } })
                end
            end
            
            -- Hunger/Thirst Damage
            if GetEntityHealth(ped) > 100 then
                if currentHunger <= 10 then
                    if hungerDamageTimer <= GetGameTimer() then
                        ApplyDamageToPed(ped, 1, false)
                        hungerDamageTimer = GetGameTimer() + 60000
                        TriggerEvent("Notify", "Aviso", "Sofrendo com a <b>fome</b>.", "fome", 5000)
                    end
                end
                
                if currentThirst <= 10 then
                    if thirstDamageTimer <= GetGameTimer() then
                        ApplyDamageToPed(ped, 1, false)
                        thirstDamageTimer = GetGameTimer() + 60000
                        TriggerEvent("Notify", "Aviso", "Sofrendo com a <b>sede</b>.", "sede", 5000)
                    end
                end
                
                -- Stress Visual Effect
                if currentStress ~= 999 and currentStress >= 50 then
                    if stressEffectTimer <= GetGameTimer() then
                        AnimpostfxPlay("MenuMGIn")
                        SetTimeout(1000, function()
                            AnimpostfxStop("MenuMGIn")
                        end)
                        stressEffectTimer = GetGameTimer() + 30000
                    end
                end
                
                -- Hunger Decay
                if currentHunger > 0 then
                    if hungerDecayTimer <= GetGameTimer() then
                        currentHunger = currentHunger - 1
                        vRPS.DowngradeHunger()
                        hungerDecayTimer = GetGameTimer() + hungerDecayInterval
                        SendNUIMessage({ Action = "Hunger", Payload = currentHunger })
                    end
                end
                
                -- Thirst Decay
                if currentThirst > 0 then
                    if thirstDecayTimer <= GetGameTimer() then
                        currentThirst = currentThirst - 1
                        vRPS.DowngradeThirst()
                        thirstDecayTimer = GetGameTimer() + thirstDecayInterval
                        SendNUIMessage({ Action = "Thirst", Payload = currentThirst })
                    end
                end
            end
        end
        
        Wait(1000)
    end
end)

-- Request System
function Creative.Request(title, message)
    if requestActive then
        return false
    end
    
    SendNUIMessage({ Action = "Request", Payload = { title, message } })
    requestTimeout = GetGameTimer() + 15000
    requestActive = true
    
    while requestActive do
        if GetGameTimer() >= requestTimeout then
            SendNUIMessage({ Action = "RequestClose" })
            requestAccepted = false
            requestActive = false
        end
        Wait(0)
    end
    
    return requestAccepted
end

RegisterNUICallback("RequestSuccess", function(data, cb)
    requestAccepted = true
    requestActive = false
    cb("Ok")
end)

RegisterNUICallback("RequestFailure", function(data, cb)
    requestAccepted = false
    requestActive = false
    cb("Ok")
end)

RegisterCommand("RequestY", function()
    if requestActive then
        SendNUIMessage({ Action = "RequestY" })
    end
end)

RegisterCommand("RequestU", function()
    if requestActive then
        SendNUIMessage({ Action = "RequestU" })
    end
end)

RegisterKeyMapping("RequestY", "Aceitar requisições.", "keyboard", "Y")
RegisterKeyMapping("RequestU", "Rejeitar requisições.", "keyboard", "U")

-- Utility: Calculate Entity Velocity
function EntityVelocity(entity)
    local velocity = GetEntityVelocity(entity)
    return math.min(math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z), 10)
end

-- State Bag Handlers
AddStateBagChangeHandler("Passport", ("player:%s"):format(LocalPlayer.state.Source), function(bagName, key, value)
    SendNUIMessage({ Action = "Passport", Payload = value })
end)

AddStateBagChangeHandler("Players", nil, function(bagName, key, value)
    SendNUIMessage({ Action = "Players", Payload = value })
end)

AddStateBagChangeHandler("Safezone", ("player:%s"):format(LocalPlayer.state.Source), function(bagName, key, value)
    SendNUIMessage({ Action = "Safezone", Payload = value and true or false })
end)

-- Voice/Radio Events
AddEventHandler("hud:Voip", function(status)
    SendNUIMessage({ Action = "Voip", Payload = status })
end)

AddEventHandler("hud:Voice", function(level)
    SendNUIMessage({ Action = "Voice", Payload = level })
end)

-- Wanted Level
RegisterNetEvent("hud:Wanted")
AddEventHandler("hud:Wanted", function(stars)
    wantedLevel = stars
    wantedTimer = stars
end)

exports("Wanted", function()
    return wantedTimer > 0
end)

-- Repose System
RegisterNetEvent("hud:Repose")
AddEventHandler("hud:Repose", function(seconds)
    reposeMaxTime = seconds
    reposeTimer = seconds
end)

exports("Repose", function()
    return reposeTimer > 0
end)

-- Video Player
RegisterNetEvent("hud:Video")
AddEventHandler("hud:Video", function(url)
    if url then
        SetNuiFocus(true, false)
        SendNUIMessage({ Action = "Body", Payload = true })
        SendNUIMessage({ Action = "Video", Payload = { true, url } })
    else
        SendNUIMessage({ Action = "Body", Payload = Display })
        SendNUIMessage({ Action = "Video", Payload = false })
        SetNuiFocus(false, false)
    end
end)

-- HUD Toggle
AddEventHandler("hud:Active", function(state)
    Display = state
    SendNUIMessage({ Action = "Body", Payload = Display })
    
    if IsMinimapRendering() then
        DisplayRadar(false)
    end
end)

CreateThread(function()
    Wait(2000)
    Display = true
    SendNUIMessage({ Action = "Body", Payload = Display })
end)

RegisterCommand("hud", function()
    Display = not Display
    SendNUIMessage({ Action = "Body", Payload = Display })
    
    if IsMinimapRendering() then
        DisplayRadar(false)
    end
end)

-- Radar System
RegisterNetEvent("hud:Radar")
AddEventHandler("hud:Radar", function()
    Radar = not Radar
    TriggerEvent("inventory:Notify", "Sucesso", "Mapa adaptativo " .. (Radar and "ativado" or "desativado") .. ".", "verde")
end)

RegisterNetEvent("hud:Radaroff")
AddEventHandler("hud:Radaroff", function()
    Radar = false
end)

RegisterNetEvent("mapa:Ativar")
AddEventHandler("mapa:Ativar", function()
    Radar = true
    DisplayRadar(true)
    SetMinimapComponentPosition("minimap", "L", "B", 0.005, -0.025, 0.175, 0.225)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.02, 0.39, 0.1135, 0.5)
    SetMinimapComponentPosition("minimap_blur", "L", "B", -0.02, -0.01, 0.265, 0.225)
    SetRadarZoom(1100)
end)

-- Progress Bar
RegisterNetEvent("Progress")
AddEventHandler("Progress", function(text, duration, itemName)
    local iconPath = itemName and ("nui://vrp/config/inventory/" .. ItemIndex(itemName) .. ".png") or nil
    SendNUIMessage({ Action = "Progress", Payload = { text, duration - 300, iconPath } })
end)

-- Stat Updates
RegisterNetEvent("hud:Thirst")
AddEventHandler("hud:Thirst", function(value)
    if currentThirst ~= value then
        SendNUIMessage({ Action = "Thirst", Payload = value })
        currentThirst = value
    end
end)

RegisterNetEvent("hud:Hunger")
AddEventHandler("hud:Hunger", function(value)
    if currentHunger ~= value then
        SendNUIMessage({ Action = "Hunger", Payload = value })
        currentHunger = value
    end
end)

RegisterNetEvent("hud:Stress")
AddEventHandler("hud:Stress", function(value)
    if currentStress ~= value then
        SendNUIMessage({ Action = "Stress", Payload = value })
        currentStress = value
    end
end)

RegisterNetEvent("hud:Luck")
AddEventHandler("hud:Luck", function(seconds)
    luckTimer = seconds
end)

RegisterNetEvent("hud:Dexterity")
AddEventHandler("hud:Dexterity", function(seconds)
    dexterityTimer = seconds
end)

-- Gemstone System
RegisterNetEvent("hud:AddGemstone")
AddEventHandler("hud:AddGemstone", function(amount)
    gemstoneCount = gemstoneCount + amount
    SendNUIMessage({ Action = "Gemstone", Payload = gemstoneCount })
end)

RegisterNetEvent("hud:RemoveGemstone")
AddEventHandler("hud:RemoveGemstone", function(amount)
    gemstoneCount = gemstoneCount - amount
    if gemstoneCount < 0 then
        gemstoneCount = 0
    end
    SendNUIMessage({ Action = "Gemstone", Payload = gemstoneCount })
end)

AddEventHandler("radio:Connect",function(Frequency)
		SendNUIMessage({ Action = "Frequency", Payload = Frequency })
end)

RegisterNetEvent("radio:Disconnect")
AddEventHandler("radio:Disconnect",function()
	SendNUIMessage({ Action = "Frequency", Payload = 'Offline' })
end)

AddEventHandler("radio:Display",function(OtherSource,Enable)
	if Enable then
		SendNUIMessage({ Action = "Radio", Payload = { Source = OtherSource, Name = Player(OtherSource).state.Name or "Desconhecido" } })
	else
		SendNUIMessage({ Action = "Radio", Payload = { Source = OtherSource } })
	end
end)

-- Special Health Mode
AddEventHandler("Health", function()
    currentHealth = 999
end)

-- Hunger/Thirst Interval Adjustments
AddEventHandler("Hunger", function(interval)
    hungerDecayInterval = interval
end)

AddEventHandler("Thirst", function(interval)
    thirstDecayInterval = interval
end)

-- Hood Toggle (Screen Fade)
RegisterNetEvent("hud:Hood")
AddEventHandler("hud:Hood", function()
    if isHoodActive then
        DoScreenFadeIn(2500)
        isHoodActive = false
    else
        DoScreenFadeOut(0)
        isHoodActive = true
    end
end)