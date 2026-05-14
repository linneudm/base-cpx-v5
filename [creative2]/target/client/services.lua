-----------------------------------------------------------------------------------------------------------------------------------------
-- PARAMEDIC SERVICE (target zones)
-----------------------------------------------------------------------------------------------------------------------------------------
local Paramedic = {
	vec3(310.2109, -593.1003, 43.0868)
}

local ParamedicServiceLabel = ""
local ResourceName = GetCurrentResourceName()

local function UpdateParamedicServiceLabel()
	local Label = LocalPlayer["state"]["Paramedico"] and "Sair de Serviço" or "Entrar em Serviço"
	if Label ~= ParamedicServiceLabel then
		ParamedicServiceLabel = Label

		for Number = 1, #Paramedic do
			local ZoneName = "ParamedicService" .. string.format("%02d", Number)
			exports[ResourceName]:LabelText(ZoneName, Label)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ONCLIENTRESOURCESTART
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onClientResourceStart", function(Resource)
	if Resource ~= ResourceName then
		return
	end

	for Number = 1, #Paramedic do
		local ZoneName = "ParamedicService" .. string.format("%02d", Number)
		exports[ResourceName]:AddCircleZone(ZoneName, Paramedic[Number], 0.15, {
			name = ZoneName,
			heading = 0.0
		}, {
			Distance = 2.0,
			options = {
				{
					event = "target:ParamedicServiceToggle",
					label = LocalPlayer["state"]["Paramedico"] and "Sair de Serviço" or "Entrar em Serviço",
					tunnel = "client"
				}
			}
		})
	end

	UpdateParamedicServiceLabel()
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- TARGET:PARAMEDICSERVICETOGGLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("target:ParamedicServiceToggle")
AddEventHandler("target:ParamedicServiceToggle", function()
	if LocalPlayer["state"]["Paramedico"] then
		TriggerServerEvent("dynamic:ExitService", "Paramedico")
	else
		TriggerServerEvent("dynamic:Service", "Paramedico")
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- TARGET:PARAMEDICREFRESHLABELS (from core ao abrir o target)
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("target:ParamedicRefreshLabels", function()
	UpdateParamedicServiceLabel()
end)
