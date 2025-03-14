-- Vernieuwd Voertuigsleutels Systeem - Client Events

-- Event voor het vergrendelen/ontgrendelen van voertuigen
RegisterNetEvent('vehiclekeys:client:ToggleVehicleLock', function()
    ToggleVehicleLock()
end)

-- Command voor het vergrendelen/ontgrendelen van voertuigen
RegisterCommand(Config.Commands.toggleLock, function()
    ToggleVehicleLock()
end, false)

-- Hotwire functionaliteit
function AttemptHotwire()
    if not NearestVehicle or NearestVehicleDistance > 3.0 then
        ShowNotification(Locales['no_vehicle_nearby'])
        return
    end
    
    local plate = GetVehicleNumberPlateText(NearestVehicle):gsub("^%s*(.-)%s*$", "%1")
    
    if HasVehicleKeys(plate) then
        ShowNotification(Locales['already_has_keys'])
        return
    end
    
    local ped = PlayerPedId()
    local vehNet = NetworkGetNetworkIdFromEntity(NearestVehicle)
    
    SetVehicleDoorsLocked(NearestVehicle, 1) -- Ontgrendel voor hotwiren
    
    -- Start hotwire animatie en progressbar
    TaskEnterVehicle(ped, NearestVehicle, 10000, -1, 1.0, 1, 0)
    
    -- Wacht tot speler in voertuig zit
    CreateThread(function()
        local timeout = 20 -- 10 seconden timeout
        while timeout > 0 do
            if IsPedInVehicle(ped, NearestVehicle, false) then
                TriggerEvent('vehiclekeys:client:StartHotwire', vehNet, plate)
                break
            end
            timeout = timeout - 1
            Wait(500)
        end
    end)
end

-- Event voor het starten van hotwiren
RegisterNetEvent('vehiclekeys:client:StartHotwire', function(vehNet, plate)
    local vehicle = NetworkGetEntityFromNetworkId(vehNet)
    if not DoesEntityExist(vehicle) then return end
    
    local ped = PlayerPedId()
    if not IsPedInVehicle(ped, vehicle, false) then return end
    
    -- Progressbar en animatie
    local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
    local anim = "machinic_loop_mechandplayer"
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    
    -- Speel hotwire geluid
    local coords = GetEntityCoords(vehicle)
    local sound = Config.Sounds.hotwire
    PlaySoundFromCoord(-1, sound.audioName, coords.x, coords.y, coords.z, sound.audioRef, false, sound.volume, false)
    
    -- Notificatie
    ShowNotification(Locales['hotwire_started'])
    
    -- Start animatie
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 16, 0, false, false, false)
    
    -- Wacht voor hotwire tijd
    local success = true
    local cancelled = false
    
    -- Controleer voor annulering
    CreateThread(function()
        while true do
            if not IsPedInVehicle(ped, vehicle, false) then
                cancelled = true
                break
            end
            Wait(100)
        end
    end)
    
    -- Hotwire timer
    Wait(Config.HotwireTime * 1000)
    
    -- Stop animatie
    StopAnimTask(ped, dict, anim, 1.0)
    
    if cancelled then
        ShowNotification(Locales['hotwire_cancelled'])
        return
    end
    
    -- Kans op mislukken (50%)
    if math.random(1, 100) > 50 then
        success = false
    end
    
    if success then
        -- Geef tijdelijke sleutels
        HasKeys[plate] = true
        ShowNotification(Locales['hotwire_success'])
        
        -- Start motor
        SetVehicleEngineOn(vehicle, true, false, true)
        
        -- Verwijder sleutels na 5 minuten
        SetTimeout(300000, function()
            if HasKeys[plate] then
                HasKeys[plate] = nil
            end
        end)
    else
        ShowNotification(Locales['hotwire_failed'])
    end
end)

-- Lockpick functionaliteit
function AttemptLockpick()
    if not NearestVehicle or NearestVehicleDistance > 3.0 then
        ShowNotification(Locales['no_vehicle_nearby'])
        return
    end
    
    local plate = GetVehicleNumberPlateText(NearestVehicle):gsub("^%s*(.-)%s*$", "%1")
    
    if HasVehicleKeys(plate) then
        ShowNotification(Locales['already_has_keys'])
        return
    end
    
    -- Controleer of speler lockpick item heeft
    if Config.UseItemKeys then
        local hasItem = false
        
        if Config.Framework == 'qbcore' then
            hasItem = Framework.Functions.HasItem(Config.LockpickItem)
        elseif Config.Framework == 'esx' then
            local xPlayer = Framework.GetPlayerFromId(GetPlayerServerId(PlayerId()))
            hasItem = xPlayer.getInventoryItem(Config.LockpickItem).count > 0
        end
        
        if not hasItem then
            ShowNotification(Locales['no_lockpick'])
            return
        end
    end
    
    local ped = PlayerPedId()
    local vehNet = NetworkGetNetworkIdFromEntity(NearestVehicle)
    
    -- Start lockpick animatie en progressbar
    TriggerEvent('vehiclekeys:client:StartLockpick', vehNet, plate)
end

-- Event voor het starten van lockpicken
RegisterNetEvent('vehiclekeys:client:StartLockpick', function(vehNet, plate)
    local vehicle = NetworkGetEntityFromNetworkId(vehNet)
    if not DoesEntityExist(vehicle) then return end
    
    local ped = PlayerPedId()
    
    -- Progressbar en animatie
    local dict = "veh@break_in@0h@p_m_one@"
    local anim = "low_force_entry_ds"
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    
    -- Speel lockpick geluid
    local coords = GetEntityCoords(vehicle)
    local sound = Config.Sounds.lockpick
    PlaySoundFromCoord(-1, sound.audioName, coords.x, coords.y, coords.z, sound.audioRef, false, sound.volume, false)
    
    -- Notificatie
    ShowNotification(Locales['lockpick_started'])
    
    -- Start animatie
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 16, 0, false, false, false)
    
    -- Wacht voor lockpick tijd
    local success = true
    local cancelled = false
    
    -- Controleer voor annulering
    CreateThread(function()
        while true do
            if #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) > 3.0 then
                cancelled = true
                break
            end
            Wait(100)
        end
    end)
    
    -- Lockpick timer
    Wait(Config.LockpickTime * 1000)
    
    -- Stop animatie
    StopAnimTask(ped, dict, anim, 1.0)
    
    if cancelled then
        ShowNotification(Locales['lockpick_cancelled'])
        return
    end
    
    -- Kans op mislukken (50%)
    if math.random(1, 100) > 50 then
        success = false
    end
    
    -- Kans dat lockpick breekt
    if math.random(1, 100) <= Config.LockpickBreakChance then
        -- Verwijder lockpick item
        if Config.UseItemKeys then
            TriggerServerEvent('vehiclekeys:server:RemoveLockpick')
        end
        ShowNotification(Locales['lockpick_broke'])
    end
    
    if success then
        -- Ontgrendel voertuig
        SetVehicleDoorsLocked(vehicle, 1)
        ShowNotification(Locales['lockpick_success'])
    else
        ShowNotification(Locales['lockpick_failed'])
    end
end)

-- Event voor het geven van sleutels aan een andere speler
RegisterNetEvent('vehiclekeys:client:GiveKeys', function(targetId)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    
    if not targetPed or targetPed == 0 then
        ShowNotification(Locales['player_not_found'])
        return
    end
    
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(coords - targetCoords)
    
    if distance > 3.0 then
        ShowNotification(Locales['no_player_nearby'])
        return
    end
    
    local vehicle = nil
    
    if IsPedInAnyVehicle(ped, false) then
        vehicle = GetVehiclePedIsIn(ped, false)
    else
        vehicle = NearestVehicle
    end
    
    if not vehicle or not DoesEntityExist(vehicle) then
        ShowNotification(Locales['no_vehicle_nearby'])
        return
    end
    
    local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
    
    if not HasVehicleKeys(plate) then
        ShowNotification(Locales['no_keys'])
        return
    end
    
    -- Geef sleutels aan doelspeler
    TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', targetId, plate)
    
    -- Notificatie
    local targetName = GetPlayerName(GetPlayerFromServerId(targetId))
    ShowNotification(string.format(Locales['keys_given'], targetName))
end)