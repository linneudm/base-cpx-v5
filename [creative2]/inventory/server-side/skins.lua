-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFERSKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.TransferSkin(OtherPassport,Selected,Weapon,Component)
    local Source = source
    local Passport = vRP.Passport(Source)

    Selected,OtherPassport = tostring(Selected),tonumber(OtherPassport)

    if not Passport or not OtherPassport or Passport == OtherPassport then return false end

    local OtherSource = vRP.Source(OtherPassport)
    if not OtherSource then
        return TriggerClientEvent("Notify",Source,"Aviso","O passaporte não existe ou não está online.","amarelo",5000,"bottom-center")
    end

    if not Users.Skins[Passport] or not Users.Skins[Passport].List or not Users.Skins[Passport].List[Selected] or Users.Skins[Passport][Weapon] == Component or Users.Skins[OtherPassport] and Users.Skins[OtherPassport].List and Users.Skins[OtherPassport].List[Selected] then
        return TriggerClientEvent("Notify",Source,"Atenção","Você não possui essa skin ou já transferiu.","vermelho",5000,"bottom-center")
    end

    Users.Skins[OtherPassport] = Users.Skins[OtherPassport] or { List = {} }
    Users.Skins[OtherPassport].List[Selected] = Users.Skins[Passport].List[Selected]
    Users.Skins[Passport].List[Selected] = nil

    TriggerClientEvent("Notify",Source,"Sucesso","Skin transferida com sucesso.","verde",5000,"bottom-center")
    TriggerClientEvent("Notify",OtherSource,"Sucesso","Você recebeu uma skin de <b>"..vRP.FullName(Passport).."</b>.","verde",5000,"bottom-center")

    exports.discord:Embed("Weaponskins","**[TIPO]:** Transferência\n**[PASSAPORTE]:** "..Passport.."\n**[PARA]:** "..OtherPassport.."\n**[NÚMERO]:** "..Selected.."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"))

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUYSKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.BuySkin(Weapon)
    local Source = source
    local Passport = vRP.Passport(Source)
    if not Passport then return false end

    local WeaponId = tostring(Weapon.id)
    Users.Skins[Passport] = Users.Skins[Passport] or { List = {} }
    if Users.Skins[Passport].List[WeaponId] then return false end

    if not vRP.PaymentGems(Passport,Weapon.price) then
        return TriggerClientEvent("Notify",Source,"Atenção","<b>"..ItemName("gemstone").."s</b> insuficiente.","vermelho",5000,"bottom-center")
    end

    Users.Skins[Passport].List[WeaponId] = Weapon.component

    TriggerClientEvent("inventory:Skins",Source,Users.Skins[Passport])
    TriggerClientEvent("Notify",Source,"Sucesso","Você comprou a skin <b>"..Weapon.name.."</b>.","verde",5000,"bottom-center")
    exports.discord:Embed("Weaponskins","**[TIPO]:** Compra\n**[PASSAPORTE]:** "..Passport.."\n**[NÚMERO]:** "..WeaponId.."\n**[DATA & HORA]:** "..os.date("%d/%m/%Y").." às "..os.date("%H:%M"))

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVESKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.ActiveSkin(Weapon,Component)
    local Source = source
    local Passport = vRP.Passport(Source)
    if not Passport then return false end

    Users.Skins[Passport] = Users.Skins[Passport] or { List = {} }
    if Users.Skins[Passport][Weapon] then return false end

    Users.Skins[Passport][Weapon] = Component
    TriggerClientEvent("inventory:Skins",Source,Users.Skins[Passport])
    vCLIENT.StoreWeapon(Source)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INACTIVESKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.InactiveSkin(Weapon)
    local Source = source
    local Passport = vRP.Passport(Source)
    if not Passport or not Users.Skins[Passport] or not Users.Skins[Passport][Weapon] then return false end

    Users.Skins[Passport][Weapon] = nil
    TriggerClientEvent("inventory:Skins",Source,Users.Skins[Passport])
    vCLIENT.StoreWeapon(Source)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERSKINS
-----------------------------------------------------------------------------------------------------------------------------------------
function Creative.UserSkins()
    local Source = source
    local Passport = vRP.Passport(Source)
    if not Passport then return false end

    Users.Skins[Passport] = Users.Skins[Passport] or { List = {} }
    Users.Skins[Passport].List = Users.Skins[Passport].List or {}

    TriggerClientEvent("inventory:Skins",Source,Users.Skins[Passport])
    return Users.Skins[Passport]
end