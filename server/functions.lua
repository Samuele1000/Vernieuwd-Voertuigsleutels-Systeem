-- Vernieuwd Voertuigsleutels Systeem - Server Functions

-- Functie om speler identifier te krijgen
function GetPlayerIdentifier(source)
    if Config.Framework == 'qbcore' then
        local Player = Framework.Functions.GetPlayer(source)
        return Player.PlayerData.citizenid
    elseif Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        return xPlayer.identifier
    elseif Config.Framework == 'qbox' then
        local Player = Framework.Functions.GetPlayer(source)
        return Player.PlayerData.citizenid
    end
    
    return nil
end

-- Functie om sleutels op te slaan in database
function SaveVehicleKeys(identifier, plate)
    if Config.UseItemKeys then
        -- Als we item-gebaseerde sleutels gebruiken, hoeven we niets op te slaan
        return
    end
    
    -- Sla sleutels op in database, afhankelijk van framework
    if Config.Framework == 'qbcore' then
        MySQL.Async.execute('INSERT INTO player_vehiclekeys (citizenid, plate) VALUES (?, ?)', {
            identifier,
            plate
        })
    elseif Config.Framework == 'esx' then
        MySQL.Async.execute('INSERT INTO player_vehiclekeys (identifier, plate) VALUES (?, ?)', {
            identifier,
            plate
        })
    end
    
    -- Update lokale cache
    if not VehicleKeys[identifier] then
        VehicleKeys[identifier] = {}
    end
    
    table.insert(VehicleKeys[identifier], plate)
end

-- Functie om sleutels te verwijderen uit database
function RemoveVehicleKeys(identifier, plate)
    if Config.UseItemKeys then
        -- Als we item-gebaseerde sleutels gebruiken, hoeven we niets te verwijderen
        return
    end
    
    -- Verwijder sleutels uit database, afhankelijk van framework
    if Config.Framework == 'qbcore' then
        MySQL.Async.execute('DELETE FROM player_vehiclekeys WHERE citizenid = ? AND plate = ?', {
            identifier,
            plate
        })
    elseif Config.Framework == 'esx' then
        MySQL.Async.execute('DELETE FROM player_vehiclekeys WHERE identifier = ? AND plate = ?', {
            identifier,
            plate
        })
    end
    
    -- Update lokale cache
    if VehicleKeys[identifier] then
        for i, vehPlate in ipairs(VehicleKeys[identifier]) do
            if vehPlate == plate then
                table.remove(VehicleKeys[identifier], i)
                break
            end
        end
    end
end

-- Functie om alle sleutels van een speler te krijgen
function GetPlayerVehicleKeys(source)
    local identifier = GetPlayerIdentifier(source)
    local keysList = {}
    
    if Config.UseItemKeys then
        -- Haal sleutels op uit inventory, afhankelijk van framework
        if Config.Framework == 'qbcore' then
            local Player = Framework.Functions.GetPlayer(source)
            local items = Player.Functions.GetItemsByName(Config.KeyItem)
            
            for _, item in pairs(items) do
                if item.info and item.info.plate then
                    keysList[item.info.plate] = true
                end
            end
        elseif Config.Framework == 'esx' then
            -- ESX heeft geen metadata voor items, dus we kunnen geen specifieke sleutels ophalen
            -- Dit is een simpele implementatie, in de praktijk zou je een custom item systeem nodig hebben
        end
    else
        -- Haal sleutels op uit database cache
        if VehicleKeys[identifier] then
            for _, plate in ipairs(VehicleKeys[identifier]) do
                keysList[plate] = true
            end
        end
    end
    
    return keysList
end

-- Functie om te controleren of een voertuig bestaat
function DoesVehicleExist(plate)
    -- In een echte implementatie zou je hier een database check doen
    -- Voor nu gaan we ervan uit dat het voertuig bestaat
    return true
end