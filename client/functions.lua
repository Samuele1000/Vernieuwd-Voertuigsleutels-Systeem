-- Vernieuwd Voertuigsleutels Systeem - Client Functions

-- Functie om te controleren of een voertuig in de blacklist staat
function IsVehicleBlacklisted(vehicle)
    local model = GetEntityModel(vehicle)
    
    for _, blacklistedModel in pairs(Config.BlacklistedVehicles) do
        if model == GetHashKey(blacklistedModel) then
            return true
        end
    end
    
    return false
end

-- Functie om dichtstbijzijnde speler te vinden
function GetClosestPlayer()
    local players = GetActivePlayers()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestDistance = -1
    local closestPlayer = -1
    
    for i = 1, #players do
        if players[i] ~= PlayerId() then
            local targetPed = GetPlayerPed(players[i])
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)
            
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end

-- Functie om motor aan/uit te zetten
function ToggleVehicleEngine()
    local vehicle = nil
    local ped = PlayerPedId()
    
    if IsPedInAnyVehicle(ped, false) then
        vehicle = GetVehiclePedIsIn(ped, false)
    else
        return
    end
    
    if not DoesEntityExist(vehicle) then return end
    
    local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
    
    if not HasVehicleKeys(plate) then
        ShowNotification(Locales['no_keys'])
        return
    end
    
    local isEngineRunning = GetIsVehicleEngineRunning(vehicle)
    
    if isEngineRunning then
        SetVehicleEngineOn(vehicle, false, false, true)
        ShowNotification(string.format(Locales['engine_toggle'], Locales['engine_off']))
    else
        SetVehicleEngineOn(vehicle, true, false, true)
        ShowNotification(string.format(Locales['engine_toggle'], Locales['engine_on']))
    end
end

-- Functie om alle sleutels te tonen die de speler heeft
function ShowVehicleKeys()
    local keysList = {}
    
    for plate, _ in pairs(HasKeys) do
        table.insert(keysList, plate)
    end
    
    if #keysList == 0 then
        ShowNotification(Locales['no_keys'])
        return
    end
    
    -- Hier zou je een menu kunnen tonen met alle sleutels
    -- Voor nu tonen we gewoon een notificatie met het aantal sleutels
    ShowNotification(string.format('Je hebt sleutels voor %d voertuigen', #keysList))
end

-- Functie om te controleren of een voertuig van de speler is
function IsVehicleOwned(plate)
    -- In een echte implementatie zou je hier een server call doen om te controleren
    -- of het voertuig eigendom is van de speler
    -- Voor nu gaan we ervan uit dat het voertuig niet van de speler is
    return false
end