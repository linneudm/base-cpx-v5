-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCORD
-----------------------------------------------------------------------------------------------------------------------------------------
local Discord = {
	["Connect"] = "",
	["Disconnect"] = "",
	["Services"] = "",
	["Salary"] = "",
	["Admin"] = "",
	["Garages"] = "",
	["Paramedic"] = "",
	["Payments"] = "",
	["Airport"] = "",
	["Deaths"] = "",
	["Gemstone"] = "",
	["Rename"] = "",
	["Roles"] = "",
	["Skins"] = "",
	["Marketplace"] = "",
	["Pause"] = "",
	["Boxes"] = "",
	["Hackers"] = ""
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- EMBED
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Embed", function(Hook, Message, Color, source)
	local url = Discord[Hook]
	if (url == "") then
		url =
		"https://discord.com/api/webhooks/1503855886194442311/6QvWI65wqE9xvvFh5G0cxzSlM4RXwlHRdS8g-qnpCWr0vXl-TgwZSBTZEr7tVytVEVG0"
	end
	PerformHttpRequest(url, function() end, "POST", json.encode({
		username = ServerName,
		embeds = {
			{ color = (Color or 0xa3c846), description = Message }
		}
	}), { ["Content-Type"] = "application/json" })

	if source then
		TriggerClientEvent("megazord:Screenshot", source, Discord[Hook])
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTENT
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Content", function(Hook, Message)
	local url = Discord[Hook]
	if (url == "") then
		url =
		"https://discord.com/api/webhooks/1503855886194442311/6QvWI65wqE9xvvFh5G0cxzSlM4RXwlHRdS8g-qnpCWr0vXl-TgwZSBTZEr7tVytVEVG0"
	end
	PerformHttpRequest(url, function() end, "POST", json.encode({
		username = ServerName,
		content = Message
	}), { ["Content-Type"] = "application/json" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Webhook", function(Hook)
	return Discord[Hook] or
			"https://discord.com/api/webhooks/1503855886194442311/6QvWI65wqE9xvvFh5G0cxzSlM4RXwlHRdS8g-qnpCWr0vXl-TgwZSBTZEr7tVytVEVG0"
end)
