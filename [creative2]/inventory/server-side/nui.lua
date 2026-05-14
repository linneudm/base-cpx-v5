-----------------------------------------------------------------------------------------------------------------------------------------
-- MOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Mount()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Primary = {}
		local Inv = vRP.Inventory(Passport)

		local function ProcessItem(v, Index)
			local data = {
				name = ItemName(v.item),
				weight = ItemWeight(v.item),
				index = ItemIndex(v.item),
				amount = parseInt(v.amount),
				rarity = ItemRarity(v.item),
				economy = ItemEconomy(v.item),
				desc = ItemDescription(v.item),
				key = v.item,
				slot = Index
			}
			return data
		end

		for Slot, v in pairs(Inv) do
			if v.amount <= 0 or not ItemExist(v.item) then
				vRP.CleanSlot(Passport, Slot)
			else
				v.key = v.item
				v.data = ProcessItem(v, Slot)

				local Split = splitString(v.item)
				local Item = Split[1]

				if not v.desc then
					if Item == "vehiclekey" and Split[3] then
						local Consult = exports["oxmysql"]:single_async("SELECT * FROM vehicles WHERE Plate = ? LIMIT 1",
							{ Split[3] })
						if Consult and VehicleExist(Consult.Vehicle) then
							v.desc = "Proprietário: <common>" ..
									vRP.FullName(Consult.Passport) ..
									"</common><br>Modelo: <common>" ..
									VehicleName(Consult.Vehicle) .. "</common><br>Placa: <common>" .. Split[3] .. "</common>"
						end
					elseif Item == "propertys" and Split[2] then
						local Consult = exports["oxmysql"]:single_async("SELECT * FROM propertys WHERE Serial = ? LIMIT 1",
							{ Split[2] })
						if Consult then
							v.desc = "Proprietário: <common>" .. vRP.FullName(Consult.Passport) .. "</common>"
						end
					elseif ItemNamed(Item) and Split[2] and vRP.Identity(Split[2]) then
						if Item == "identity" then
							v.desc = "Passaporte: <rare>" ..
									Dotted(Split[2]) ..
									"</rare><br>Nome: <rare>" ..
									vRP.FullName(Split[2]) .. "</rare><br>Telefone: <rare>" .. vRP.GetPhone(Split[2]) .. "</rare>"
						else
							v.desc = "Proprietário: <common>" .. vRP.FullName(Split[2]) .. "</common>"
						end
					end
				end

				if Split[2] then
					local Loaded = ItemLoads(v.item)
					if Loaded then
						v.charges = parseInt(Split[2] * (100 / Loaded))
					end

					if ItemDurability(v.item) then
						v.durability = parseInt(os.time() - Split[2])
						v.days = ItemDurability(v.item)
					end
				end
				Primary[Slot] = v
			end
		end

		return Primary, vRP.GetWeight(Passport)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- BLUEPRINT
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Blueprint()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Users["Blueprints"][Passport] then
		local Primary = {}
		local Inv = vRP.Inventory(Passport)
		for Slot, v in pairs(Inv) do
			if v.amount <= 0 or not ItemExist(v.item) then
				vRP.CleanSlot(Passport, Slot)
			else
				v.key = v.item

				local Split = splitString(v.item)
				local Item = Split[1]

				if not v.desc then
					if Item == "vehiclekey" and Split[3] then
						local Consult = exports["oxmysql"]:single_async("SELECT * FROM vehicles WHERE Plate = ? LIMIT 1",
							{ Split[3] })
						if Consult and VehicleExist(Consult.Vehicle) then
							v.desc = "Proprietário: <common>" ..
									vRP.FullName(Consult.Passport) ..
									"</common><br>Modelo: <common>" ..
									VehicleName(Consult.Vehicle) .. "</common><br>Placa: <common>" .. Split[3] .. "</common>"
						end
					elseif Item == "propertys" and Split[2] then
						local Consult = exports["oxmysql"]:single_async("SELECT * FROM propertys WHERE Serial = ? LIMIT 1",
							{ Split[2] })
						if Consult then
							v.desc = "Proprietário: <common>" .. vRP.FullName(Consult.Passport) .. "</common>"
						end
					elseif ItemNamed(Item) and Split[2] and vRP.Identity(Split[2]) then
						if Item == "identity" then
							v.desc = "Passaporte: <rare>" ..
									Dotted(Split[2]) ..
									"</rare><br>Nome: <rare>" ..
									vRP.FullName(Split[2]) .. "</rare><br>Telefone: <rare>" .. vRP.Phone(Split[2]) .. "</rare>"
						else
							v.desc = "Proprietário: <common>" .. vRP.FullName(Split[2]) .. "</common>"
						end
					end
				end

				if Split[2] then
					local Loaded = ItemLoads(v.item)
					if Loaded then
						v.charges = parseInt(Split[2] * (100 / Loaded))
					end

					if ItemDurability(v.item) then
						v.durability = parseInt(os.time() - Split[2])
						v.days = ItemDurability(v.item)
					end
				end

				Primary[Slot] = v
			end
		end

		local Secondary = {}
		for Item, v in pairs(Users.Blueprints[Passport]) do
			if (not ItemExist(Item) or not ItemExist("blueprint_" .. Item)) and Users.Blueprints[Passport][Item] then
				Users.Blueprints[Passport][Item] = nil
			else
				local Calculated = CountTable(Secondary) + 1
				local Number = tostring(Calculated)

				Secondary[Number] = { key = Item, amount = 1 }

				if Crafting[Item] then
					Secondary[Number].required = {}

					for Index, Amount in pairs(Crafting[Item].Required) do
						local Rarity = ItemRarity(Index)

						table.insert(Secondary[Number].required,
							"<" .. Rarity .. ">" .. Dotted(Amount) .. "x " .. ItemName(Index) .. "</" .. Rarity .. ">")
					end
				end
			end
		end

		return Primary, Secondary, vRP.GetWeight(Passport)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- MISSIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Missions()
	local List = {}
	local source = source
	local Passport = vRP.Passport(source)

	if not Passport then
		return List
	end

	local Consult = vRP.SimpleData(Passport, "Missions")
	for Index, v in pairs(Missions) do
		List[Index] = v
		List[Index].Active = Consult and Consult[v.Code] and true or false
	end

	return {
		vRP.GetExperience(Passport, "Missions"), TableLevel(), List
	}
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- RESCUEMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.RescueMission(Index)
	local source = source
	local Passport = vRP.Passport(source)

	if not Passport or not Missions[Index] then
		return false
	end

	local Code = Missions[Index].Code
	local Consult = vRP.SimpleData(Passport, "Missions")
	if not Code or (Consult and Consult[Code]) then
		return false
	end

	for Item, Amount in pairs(Missions[Index].Required) do
		if not vRP.ConsultItem(Passport, Item, Amount) then
			TriggerClientEvent("inventory:Notify", source, "Atenção",
				"Precisa de11 <default>" .. Dotted(Amount) .. "x " .. ItemName(Item) .. "</default>.", "vermelho")
			return false
		end
	end

	for Item, Amount in pairs(Missions[Index].Required) do
		vRP.RemoveItem(Passport, Item, Amount)
	end

	for Item, Amount in pairs(Missions[Index].Rewards) do
		vRP.GenerateItem(Passport, Item, Amount)
	end

	if Missions[Index].Xp then
		vRP.PutExperience(Passport, "Missions", Missions[Index].Xp)
	end

	Consult = Consult or {}
	Consult[Code] = true

	vRP.Query("playerdata/SetData", { Passport = Passport, Name = "Missions", Information = json.encode(Consult) })

	return true
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Player()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport then
		local Identity = vRP.Identity(Passport)
		if Identity then
			return {
				Passport = Passport,
				Name = Identity.Name .. " " .. Identity.Lastname,
				Gemstone = vRP.UserGemstone(Identity.License) or 0
			}
		end
	end

	return {
		Passport = 0,
		Name = "Desconhecido",
		Gemstone = 0
	}
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- IDENTITY
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Identity(Passport)
	local TargetPassport = Passport

	if TargetPassport and TargetPassport > 0 then
		local Identity = vRP.Identity(TargetPassport)

		if Identity and Identity.Name and Identity.Lastname then
			local Avatar = "images/user.svg"

			-- Tentar puxar avatar local primeiro
			local Avatars = vRP.UserData(TargetPassport, "Avatars")
			if Avatars and Avatars.Image then
				Avatar = Avatars.Image
			else
				-- Fallback para Discord
				if exports["discord"] and exports["discord"].Avatar then
					Avatar = exports["discord"]:Avatar(TargetPassport) or "images/user.svg"
				end
			end

			local Result = {
				Avatar = Avatar,
				Passport = TargetPassport,
				Name = Identity.Name .. " " .. Identity.Lastname,
				Sex = Identity.Sex or "M",
				Gemstone = 0,
				Job = "Desempregado"
			}

			if Identity.License and vRP.UserGemstone then
				Result.Gemstone = vRP.UserGemstone(Identity.License) or 0
			end

			if vRP.UserGroup then
				Result.Job = vRP.UserGroup(TargetPassport) or "Desempregado"
			end

			return Result
		else
		end
	else
	end

	local DefaultResult = {
		Avatar = "images/user.svg",
		Passport = 0,
		Name = "Desconhecido",
		Sex = "M",
		Gemstone = 0,
		Job = "Desempregado"
	}

	return DefaultResult
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CRAFTING
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.Crafting(Item, Amount, Target)
	local source = source
	local Target = tostring(Target)
	local Amount = parseInt(Amount, true)
	local Passport = vRP.Passport(source)
	if Passport and Item and Target and Crafting[Item] then
		if Amount > 1 and (ItemUnique(Item) or ItemLoads(Item)) then
			Amount = 1
		end

		local Inventory = vRP.Inventory(Passport)
		local Multiplier = Crafting[Item].Amount * Amount
		if not vRP.MaxItens(Passport, Item, Multiplier) and vRP.CheckWeight(Passport, Item, Multiplier) and (not Inventory[Target] or (Inventory[Target] and Inventory[Target].item == Item)) then
			for Index, Value in pairs(Crafting[Item].Required) do
				if not vRP.ConsultItem(Passport, Index, Value * Amount) then
					TriggerClientEvent("inventory:Notify", source, "Atenção",
						"Precisa de <default>" .. Dotted(Value * Amount) .. "x " .. ItemName(Index) .. "</default>.", "vermelho")

					return false
				end
			end

			for Index, Value in pairs(Crafting[Item].Required) do
				vRP.RemoveItem(Passport, vRP.InventoryItemAmount(Passport, Index)[2], Value * Amount)
			end

			vRP.GenerateItem(Passport, Item, Multiplier, false, Target)
		end
	end

	TriggerClientEvent("inventory:Update", source)
end
