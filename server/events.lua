-- Vernieuwd Voertuigsleutels Systeem - Server Events

-- Event voor het ophalen van voertuigsleutels bij inloggen
RegisterNetEvent('vehiclekeys:server:GetVehicleKeys', function()
    local src = source
    local keysList = GetPlayerVehicleKeys(src)
    
    TriggerClientEvent('vehiclekeys:client:SetVehicleKeys', src, keysList)
end)

-- Event voor het toevoegen van voertuigsleutels
RegisterNetEvent('vehiclekeys:server:AddVehicleKeys', function(plate)
    local src = source
    
    if not plate then return end
    
    -- Controleer of voertuig bestaat
    if not DoesVehicleExist(plate) then
        TriggerClientEvent('vehiclekeys:client:ShowNotification', src, Locales['vehicle_not_exists'])
        return
    end
    
    -- Voeg sleutels toe
    if Config.UseItemKeys then
        -- Geef sleutelitem aan speler
        if Config.Framework == 'qbcore' then
            local Player = Framework.Functions.GetPlayer(src)
            
            Player.Functions.AddItem(Config.KeyItem, 1, nil, {
                plate = plate
            })
            
            TriggerClientEvent('inventory:client:ItemBox', src, Framework.Shared.Items[Config.KeyItem], 'add')
        elseif Config.Framework == 'esx' then
            local xPlayer = Framework.GetPlayerFromId(src)
            xPlayer.addInventoryItem(Config.KeyItem, 1)
        end
    else
        -- Sla sleutels op in database
        local identifier = GetPlayerIdentifier(src)
        SaveVehicleKeys(identifier, plate)
    end
    
    -- Stuur sleutels naar client
    TriggerClientEvent('vehiclekeys:client:AddVehicleKeys', src, plate)
end)

-- Event voor het verwijderen van voertuigsleutels
RegisterNetEvent('vehiclekeys:server:RemoveVehicleKeys', function(plate)
    local src = source
    
    if not plate then return end
    
    -- Verwijder sleutels
    if Config.UseItemKeys then
        -- Verwijder sleutelitem van speler
        if Config.Framework == 'qbcore' then
            local Player = Framework.Functions.GetPlayer(src)
            local items = Player.Functions.GetItemsByName(Config.KeyItem)
            
            for _, item in pairs(items) do
                if item.info and item.info.plate == plate then
                    Player.Functions.RemoveItem(item.name, 1, item.slot)
                    TriggerClientEvent('inventory:client:ItemBox', src, Framework.Shared.Items[Config.KeyItem], 'remove')
                    break
                end
            end
        elseif Config.Framework == 'esx' then
            local xPlayer = Framework.GetPlayerFromId(src)
            xPlayer.removeInventoryItem(Config.KeyItem, 1)
        end
    else
        -- Verwijder sleutels uit database
        local identifier = GetPlayerIdentifier(src)
        RemoveVehicleKeys(identifier, plate)
    end
    
    -- Stuur update naar client
    TriggerClientEvent('vehiclekeys:client:RemoveVehicleKeys', src, plate)
end)

-- Event voor het geven van sleutels aan een andere speler
RegisterNetEvent('vehiclekeys:server:GiveVehicleKeys', function(targetId, plate)
    local src = source
    
    if not targetId or not plate then return end
    
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
    
    -- Controleer of speler sleutels heeft
    if not HasVehicleKeys(src, plate) then
        TriggerClientEvent('vehiclekeys:client:ShowNotification', src, Locales['no_keys'])
        return
    end
    
    -- Controleer of doelspeler al sleutels heeft
    if HasVehicleKeys(targetId, plate) then
        TriggerClientEvent('vehiclekeys:client:ShowNotification', src, Locales['already_has_keys'])
        return
    end
    
    -- Geef sleutels aan doelspeler
    if Config.UseItemKeys then
        -- Geef sleutelitem aan doelspeler
        if Config.Framework == 'qbcore' then
            local Player = Framework.Functions.GetPlayer(targetId)
            
            Player.Functions.AddItem(Config.KeyItem, 1, nil, {
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
    TriggerClientEvent('vehiclekeys:client:ShowNotification', targetId, Locales['received_keys'])
end)

-- Event voor het verwijderen van lockpick item
RegisterNetEvent('vehiclekeys:server:RemoveLockpick', function()
    local src = source
    
    if Config.Framework == 'qbcore' then
        local Player = Framework.Functions.GetPlayer(src)
        Player.Functions.RemoveItem(Config.LockpickItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, Framework.Shared.Items[Config.LockpickItem], 'remove')
    elseif Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(src)
        xPlayer.removeInventoryItem(Config.LockpickItem, 1)
    end
end)