-- Vernieuwd Voertuigsleutels Systeem - Client Commands

-- Command voor het geven van sleutels aan een andere speler
RegisterCommand(Config.Commands.giveKeys, function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        ShowNotification(string.format(Locales['cmd_givekeys_usage'], Config.Commands.giveKeys))
        return
    end
    
    TriggerEvent('vehiclekeys:client:GiveKeys', targetId)
end, false)

-- Admin command voor het toevoegen van sleutels
RegisterCommand(Config.Commands.addKeys, function(source, args)
    if not IsPlayerAdmin() then
        ShowNotification(Locales['no_permission'])
        return
    end
    
    local targetId = tonumber(args[1])
    local plate = args[2]
    
    if not targetId or not plate then
        ShowNotification(string.format(Locales['cmd_addkeys_usage'], Config.Commands.addKeys))
        return
    end
    
    -- Controleer of kenteken geldig is
    if string.len(plate) < 2 or string.len(plate) > 8 then
        ShowNotification(Locales['invalid_plate'])
        return
    end
    
    -- Voeg sleutels toe aan speler
    TriggerServerEvent('vehiclekeys:server:AdminAddKeys', targetId, plate)
end, false)

-- Admin command voor het verwijderen van sleutels
RegisterCommand(Config.Commands.removeKeys, function(source, args)
    if not IsPlayerAdmin() then
        ShowNotification(Locales['no_permission'])
        return
    end
    
    local targetId = tonumber(args[1])
    local plate = args[2]
    
    if not targetId or not plate then
        ShowNotification(string.format(Locales['cmd_removekeys_usage'], Config.Commands.removeKeys))
        return
    end
    
    -- Controleer of kenteken geldig is
    if string.len(plate) < 2 or string.len(plate) > 8 then
        ShowNotification(Locales['invalid_plate'])
        return
    end
    
    -- Verwijder sleutels van speler
    TriggerServerEvent('vehiclekeys:server:AdminRemoveKeys', targetId, plate)
end, false)

-- Functie om te controleren of speler admin is
function IsPlayerAdmin()
    if Config.Framework == 'qbcore' then
        local Player = Framework.Functions.GetPlayerData()
        return Player.PlayerData.admin or Player.PlayerData.permission == 'admin' or Player.PlayerData.permission == 'god'
    elseif Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerData()
        return xPlayer.group == 'admin' or xPlayer.group == 'superadmin'
    end
    
    return false
end