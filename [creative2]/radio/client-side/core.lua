-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("radio")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Volume = 0
local Frequency = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- RADIO:OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("radio:Open")
AddEventHandler("radio:Open", function()
  if not LocalPlayer["state"]["Prison"] then
    SetNuiFocus(true, true)
    SetCursorLocation(0.9, 0.9)
    SendNUIMessage({ Action = "Open" })
    TriggerServerEvent("radio:RequestSlots")

    if not IsPedInAnyVehicle(PlayerPedId()) then
      vRP.CreateObjects("cellphone@", "cellphone_text_in", "prop_cs_hand_radio", 50, 28422)
    end
  end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RADIO:SETSLOTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("radio:SetSlots")
AddEventHandler("radio:SetSlots", function(Slots)
  SendNUIMessage({ Action = "Slots", Payload = Slots or 1 })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Close", function(Data, Callback)
  SetCursorLocation(0.5, 0.5)
  SetNuiFocus(false, false)
  vRP.Destroy()

  Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RADIOACTIVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("RadioActive", function(Data, Callback)
  if MumbleIsConnected() then
    if Frequency ~= Data.Frequency then
      if vSERVER.Frequency(Data.Frequency) then
        if 0 ~= Frequency then
          exports["pma-voice"]:removePlayerFromRadio()
        end

        if Data.Radio then
          TriggerEvent("mdt:Notify", "Radiofrequência", "Entrou na frequência <b>" .. Data.Frequency .. "</b>.", "verde")
          SendNUIMessage({ Action = "Radio", Payload = Data.Frequency })
        else
          TriggerEvent("Notify", "Radiofrequência", "Entrou na frequência <b>" .. Data.Frequency .. "</b>.", "verde",
            5000)
        end

        exports["pma-voice"]:setRadioChannel(Data.Frequency)
        TriggerEvent("sounds:Private", "radioon", 0.5)
        TriggerEvent("radio:Connect", Data.Frequency)
        Frequency = Data.Frequency
      end
    end
  end

  Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RADIOINATIVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("RadioInative", function(Data, Callback)
  TriggerEvent("radio:RadioClean")

  Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RADIO:RADIOCLEAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("radio:RadioClean")
AddEventHandler("radio:RadioClean", function()
  if 0 ~= Frequency then
    TriggerEvent("sounds:Private", "radiooff", 1.0)
    exports["pma-voice"]:removePlayerFromRadio()
    TriggerEvent("radio:Disconnect")
    SendNUIMessage({ Action = "Radio", Payload = "" })
    Frequency = 0
  end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETVOLUME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("SetVolume", function(Data, Callback)
  local NumberVolume = tonumber(Data.Volume) or 50
  exports["pma-voice"]:setRadioVolume(NumberVolume)

  local CurrentTime = GetGameTimer()
  if (CurrentTime - Volume) > 1000 then
    TriggerEvent("Notify", "Configurações", "<b>Volume:</b> " .. NumberVolume .. "%", "verde", 5000)
    Volume = CurrentTime
  end

  Callback("Ok")
end)
