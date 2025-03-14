-- Vernieuwd Voertuigsleutels Systeem - Server Commands

-- Admin command voor het toevoegen van sleutels
RegisterNetEvent('vehiclekeys:server:AdminAddKeys', function(targetId, plate)
    local src = source
    
    -- Controleer of speler admin is
    if not IsPlayerAdmin(src) then
        TriggerClientEvent('vehiclekeys:client:ShowNotification', src, Locales['no_permission'])
        return
    end
    
    -- Controleer of doelspeler bestaat
    local targetPlayer = nil
    
    if Config.Framework == 'qbcore' then
        targetPlayer = Framework.Functions.GetPlayer(targetId)
    elseif Config.Framework == 'esx' then
        targetPlayer = Framework.GetPlayerFromId(targetId)
    end
    
    if not targetPlayer then
        TriggerClientEvent('vehiclekeys:client:ShowNotification', src, Locales['player_not_found'])
        return
    end
    
    -- Voeg sleutels toe aan doelspeler
    if Config.UseItemKeys then
        -- Geef sleutelitem aan doelspeler
        if Config.Framework == 'qbcore' then
            targetPlayer.Functions.AddItem(Config.KeyItem, 1, nil, {
                plate = plate
            })
            
            TriggerClientEvent('inventory:client:ItemBox', targetId, Framework.Shared.Items[Config.KeyItem], 'add')
        elseif Config.Framework == 'esx' then
            local xPlayer = Framework.GetPlayerFromId(targetId)
            xPlayer.addInventoryItem(Config.KeyItem, 1)
        end
    else
        -- Sla sleutels op in database
        local identifier = GetPlayerIdentifier(targetId)
        SaveVehicleKeys(identifier, plate)
    end
    
    -- Stuur sleutels naar client
    TriggerClientEvent('vehiclekeys:client:AddVehicleKeys', targetId, plate)
    
    -- Notificaties
    TriggerClientEvent('vehiclekeys:client:ShowNotification', src, string.format(Locales['keys_added'], plate, GetPlayerName(targetId)))
    TriggerClientEvent('vehiclekeys:client:ShowNotification', targetId, Locales['received_keys'])
end)

-- Admin command voor het verwijderen van sleutels
RegisterNetEvent('vehiclekeys:server:AdminRemoveKeys', function(targetId, plate)
    local src = source
    
    -- Controleer of speler admin is
    if not IsPlayerAdmin(src) then
        TriggerClientEvent('vehiclekeys:client:ShowNotification', src, Locales['no_permission'])
        return
    end
    
    -- Controleer of doelspeler bestaat
    local targetPlayer = nil
    
    if Config.Framework == 'qbcore' then
        targetPlayer = Framework.Functions.GetPlayer(targetId)
    elseif Config.Framework == 'esx' then
        targetPlayer = Framework.GetPlayerFromId(targetId)
    end
    
    if not targetPlayer then
        TriggerClientEvent('vehiclekeys:client:ShowNotification', src, Locales['player_not_found'])
        return
    end
    
    -- Verwijder sleutels van doelspeler
    if Config.UseItemKeys then
        -- Verwijder sleutelitem van doelspeler
        if Config.Framework == 'qbcore' then
            local items = targetPlayer.Functions.GetItemsByName(Config.KeyItem)
            
            for _, item in pairs(items) do
                if item.info and item.info.plate == plate then
                    targetPlayer.Functions.RemoveItem(item.name, 1, item.slot)
                    TriggerClientEvent('inventory:client:ItemBox', targetId, Framework.Shared.Items[Config.KeyItem], 'remove')
                    break
                end
            end
        elseif Config.Framework == 'esx' then
            local xPlayer = Framework.GetPlayerFromId(targetId)
            xPlayer.removeInventoryItem(Config.KeyItem, 1)
        end
    else
        -- Verwijder sleutels uit database
        local identifier = GetPlayerIdentifier(targetId)
        RemoveVehicleKeys(identifier, plate)
    end
    
    -- Stuur update naar client
    TriggerClientEvent('vehiclekeys:client:RemoveVehicleKeys', targetId, plate)
    
    -- Notificaties
    TriggerClientEvent('vehiclekeys:client:ShowNotification', src, string.format(Locales['keys_removed'], plate, GetPlayerName(targetId)))
end)

-- Functie om te controleren of speler admin is
function IsPlayerAdmin(source)
    if Config.Framework == 'qbcore' then
        local Player = Framework.Functions.GetPlayer(source)
        return Player.PlayerData.admin or Player.PlayerData.permission == 'admin' or Player.PlayerData.permission == 'god'
    elseif Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        return xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin'
    end
    
    return false
end