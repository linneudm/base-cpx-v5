-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vRP:Active")
AddEventHandler("vRP:Active", function(Passport, Name)
	SetDiscordAppId(1503855886194442311)
	SetDiscordRichPresenceAsset("LMDEV")
	SetRichPresence("#" .. Passport .. " " .. Name)
	SetDiscordRichPresenceAssetSmall("LMDEV")
	SetDiscordRichPresenceAssetText("LMDEV")
	SetDiscordRichPresenceAssetSmallText("LMDEV")
	SetDiscordRichPresenceAction(0, "LMDEV", ServerLink)
end)
