local cdsMode  = false
local nuiOpen  = false

------------------------------------------------
-- /cds  →  abre/fecha painel
------------------------------------------------
RegisterCommand("dogcds", function()
    nuiOpen = not nuiOpen
    SetNuiFocus(nuiOpen, nuiOpen)
    SendNUIMessage({ type = "toggleUI", visible = nuiOpen })
end, false)

------------------------------------------------
-- NUI CALLBACKS
------------------------------------------------
RegisterNUICallback("closeUI", function(_, cb)
    nuiOpen = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("setCDSMode", function(data, cb)
    cdsMode = data.active
    -- mostra/esconde mira via NUI (crosshair é desenhado no HTML)
    SendNUIMessage({ type = "setCrosshair", visible = cdsMode and not nuiOpen })
    cb("ok")
end)

RegisterNUICallback("captureAim", function(_, cb)
    local hit, coords = RayCastGamePlayCamera(1000.0)
    if hit == 1 then
        local ped = PlayerPedId()
        local x, y, z = Round(coords.x), Round(coords.y), Round(coords.z)
        local h = tonumber(string.format("%.2f", GetEntityHeading(ped)))
        SendNUIMessage({ type = "addCapture", source = "aim", data = BuildFormats(x, y, z, h) })
    else
        SendNUIMessage({ type = "captureError" })
    end
    cb("ok")
end)

RegisterNUICallback("capturePed", function(_, cb)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local x, y, z = Round(pos.x), Round(pos.y), Round(pos.z)
    local h = tonumber(string.format("%.2f", GetEntityHeading(ped)))
    SendNUIMessage({ type = "addCapture", source = "ped", data = BuildFormats(x, y, z, h) })
    cb("ok")
end)

------------------------------------------------
-- HOTKEYS  (modo ativo + painel fechado)
------------------------------------------------
CreateThread(function()
    while true do
        Wait(0)
        if cdsMode and not nuiOpen then

            if IsControlJustPressed(0, 38) then   -- E → mira
                local hit, coords = RayCastGamePlayCamera(1000.0)
                if hit == 1 then
                    local ped = PlayerPedId()
                    local x, y, z = Round(coords.x), Round(coords.y), Round(coords.z)
                    local h = tonumber(string.format("%.2f", GetEntityHeading(ped)))
                    SendNUIMessage({ type = "addCapture", source = "aim", data = BuildFormats(x, y, z, h) })
                end
            end

            if IsControlJustPressed(0, 23) then   -- F → ped
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local x, y, z = Round(pos.x), Round(pos.y), Round(pos.z)
                local h = tonumber(string.format("%.2f", GetEntityHeading(ped)))
                SendNUIMessage({ type = "addCapture", source = "ped", data = BuildFormats(x, y, z, h) })
            end

        else
            Wait(200)
        end
    end
end)

-- atualiza visibilidade da mira quando painel abre/fecha
CreateThread(function()
    local last = nuiOpen
    while true do
        Wait(100)
        if nuiOpen ~= last then
            last = nuiOpen
            SendNUIMessage({ type = "setCrosshair", visible = cdsMode and not nuiOpen })
        end
    end
end)

------------------------------------------------
-- HELPERS
------------------------------------------------
function Round(n)
    return tonumber(string.format("%.4f", n))
end

function BuildFormats(x, y, z, h)
    return {
        vector3    = ("vector3(%s, %s, %s)"):format(x,y,z),
        vector4    = ("vector4(%s, %s, %s, %s)"):format(x,y,z,h),
        xyz        = ("%s, %s, %s"):format(x,y,z),
        xyzh       = ("%s, %s, %s, %s"):format(x,y,z,h),
        configXYZ  = ("x = %s, y = %s, z = %s,"):format(x,y,z),
        configXYZH = ("x = %s, y = %s, z = %s, h = %s,"):format(x,y,z,h),
        vec3alt    = ("coords = vec3(%s, %s, %s)"):format(x,y,z),
        heading    = h,
        raw        = { x=x, y=y, z=z, h=h }
    }
end

function RayCastGamePlayCamera(distance)
    local rot   = GetGameplayCamRot()
    local coord = GetGameplayCamCoord()
    local dir   = RotationToDirection(rot)
    local dest  = vector3(
        coord.x + dir.x * distance,
        coord.y + dir.y * distance,
        coord.z + dir.z * distance
    )
    local ray = StartShapeTestRay(coord.x, coord.y, coord.z,
                                   dest.x,  dest.y,  dest.z,
                                   -1, PlayerPedId(), 0)
    local _, hit, endCoords = GetShapeTestResult(ray)
    return hit, endCoords
end

function RotationToDirection(r)
    local ax = math.rad(r.x)
    local az = math.rad(r.z)
    return {
        x = -math.sin(az) * math.abs(math.cos(ax)),
        y =  math.cos(az) * math.abs(math.cos(ax)),
        z =  math.sin(ax)
    }
end