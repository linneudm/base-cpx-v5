local lastTotalAmmo = -1
local lastClipAmmo = -1
local isActive = false

AddEventHandler("hud:Weapon", function(enabled, weaponName)
    if enabled then
        isActive = true
        
        while isActive do
            local ped = PlayerPedId()
            local weaponHash = GetHashKey(weaponName)
            
            local _, clipAmmo = GetAmmoInClip(ped, weaponHash)
            local totalAmmo = GetAmmoInPedWeapon(ped, weaponHash)
            
            if lastTotalAmmo ~= totalAmmo or lastClipAmmo ~= clipAmmo then
                lastTotalAmmo = totalAmmo
                lastClipAmmo = clipAmmo
                
                local reserveAmmo = totalAmmo - clipAmmo
                if reserveAmmo <= 0 then
                    reserveAmmo = 0
                end
                
                SendNUIMessage({
                    Action = "Weapons",
                    Payload = {
                        true,
                        clipAmmo,
                        reserveAmmo,
                        ItemName(weaponName),
                        weaponName
                    }
                })
            end
            
            Wait(100)
        end
    else
        SendNUIMessage({
            Action = "Weapons",
            Payload = false
        })
        
        isActive = false
        lastTotalAmmo = -1
        lastClipAmmo = -1
    end
end)
