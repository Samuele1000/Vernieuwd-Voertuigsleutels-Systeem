-- Vernieuwd Voertuigsleutels Systeem - Server Main
local Framework = nil
local VehicleKeys = {}

-- Framework initialisatie
CreateThread(function()
    if Config.Framework == 'qbcore' then
        Framework = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == 'esx' then
        Framework = exports['es_extended']:getSharedObject()
    elseif Config.Framework == 'qbox' then
        Framework = exports['qbx-core']:GetCoreObject()
    end
    
    -- Laad opgeslagen sleutels uit database
    LoadVehicleKeys()
end)

-- Functie om sleutels te laden uit database
function LoadVehicleKeys()
    if Config.UseItemKeys then
        -- Als we item-gebaseerde sleutels gebruiken, hoeven we niets te laden
        return
    end
    
    -- Laad sleutels uit database, afhankelijk van framework
    if Config.Framework == 'qbcore' then
        local result = MySQL.Sync.fetchAll('SELECT * FROM player_vehiclekeys', {})
        
        if result and #result > 0 then
            for _, data in ipairs(result) do
                if not VehicleKeys[data.citizenid] then
                    VehicleKeys[data.citizenid] = {}
                end
                
                table.insert(VehicleKeys[data.citizenid], data.plate)
            end
        end
    elseif Config.Framework == 'esx' then
        local result = MySQL.Sync.fetchAll('SELECT * FROM player_vehiclekeys', {})
        
        if result and #result > 0 then
            for _, data in ipairs(result) do
                if not VehicleKeys[data.identifier] then
                    VehicleKeys[data.identifier] = {}
                end
                
                table.insert(VehicleKeys[data.identifier], data.plate)
            end
        end
    end
end

-- Functie om te controleren of speler sleutels heeft
function HasVehicleKeys(source, plate)
    local identifier = GetPlayerIdentifier(source)
    
    if Config.UseItemKeys then
        -- Controleer of speler sleutelitem heeft
        if Config.Framework == 'qbcore' then
            local Player = Framework.Functions.GetPlayer(source)
            local items = Player.Functions.GetItemsByName(Config.KeyItem)
            
            for _, item in pairs(items) do
                if item.info and item.info.plate == plate then
                    return true
                end
            end
        elseif Config.Framework == 'esx' then
            local xPlayer = Framework.GetPlayerFromId(source)
            local items = xPlayer.getInventoryItem(Config.KeyItem)
            
            -- ESX heeft geen metadata voor items, dus we moeten een andere manier vinden
            -- Dit is een simpele implementatie, in de praktijk zou je een custom item systeem nodig hebben
            return items.count > 0
        end
    else
        -- Controleer of speler sleutels heeft in database
        if VehicleKeys[identifier] then
            for _, vehPlate in pairs(VehicleKeys[identifier]) do
                if vehPlate == plate then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Functie om sleutels toe te voegen
function AddVehicleKeys(source, plate)
    local identifier = GetPlayerIdentifier(source)
    
    if Config.UseItemKeys then
        -- Geef sleutelitem aan speler
        if Config.Framework == 'qbcore' then
            local Player = Framework.Functions.GetPlayer(source)
            
            Player.Functions.AddItem(Config.KeyItem, 1, nil, {
                plate = plate
            })
            
            TriggerClientEvent('inventory:client:ItemBox', source, Framework.Shared.Items[Config.KeyItem], 'add')
        elseif Config.Framework == 'esx' then
            local xPlayer = Framework.GetPlayerFromId(source)
            xPlayer.addInvent