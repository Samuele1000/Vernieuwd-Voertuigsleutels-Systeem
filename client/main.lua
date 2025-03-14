-- Vernieuwd Voertuigsleutels Systeem - Client Main
local Framework = nil
local PlayerData = {}
local HasKeys = {}
local NearestVehicle = nil
local NearestVehicleDistance = 0
local isLoggedIn = false

-- Framework initialisatie
CreateThread(function()
    Framework = exports['framework']:GetSharedObject()
    
    if Config.Framework == 'qbcore' then
        Framework = exports['qb-core']:GetCoreObject()
        
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = Framework.Functions.GetPlayerData()
            isLoggedIn = true
            TriggerServerEvent('vehiclekeys:server:GetVehicleKeys')
        end)
        
        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            isLoggedIn = false
            PlayerData = {}
            HasKeys = {}
        end)
        
        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
            PlayerData.job = JobInfo
        end)
    elseif Config.Framework == 'esx' then
        Framework = exports['es_extended']:getSharedObject()
        
        RegisterNetEvent('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
            isLoggedIn = true
            TriggerServerEvent('vehiclekeys:server:GetVehicleKeys')
        end)
        
        RegisterNetEvent('esx:onPlayerLogout', function()
            isLoggedIn = false
            PlayerData = {}
            HasKeys = {}
        end)
        
        RegisterNetEvent('esx:setJob', function(job)
            PlayerData.job = job
        end)
    elseif Config.Framework == 'qbox' then
        Framework = exports['qbx-core']:GetCoreObject()
        
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = Framework.Functions.GetPlayerData()
            isLoggedIn = true
            TriggerServerEvent('vehiclekeys:server:GetVehicleKeys')
        end)
        
        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            isLoggedIn = false
            PlayerData = {}
            HasKeys = {}
        end)
        
        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
            PlayerData.job = JobInfo
        end)
    end
end)

-- Hoofdfunctie voor het vinden van het dichtstbijzijnde voertuig
CreateThread(function()
    while true do
        if isLoggedIn then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local inVehicle = IsPedInAnyVehicle(ped, false)
            local vehicle = nil
            
            if inVehicle then
                vehicle = GetVehiclePedIsIn(ped, false)
                NearestVehicle = vehicle
                NearestVehicleDistance = 0
            else
                vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 10.0, 0, 71)
                if DoesEntityExist(vehicle) then
                    local vehpos = GetEntityCoords(vehicle)
                    local distance = #(pos - vehpos)
                    
                    if distance <= Config.LockDistance then
                        NearestVehicle = vehicle
                        NearestVehicleDistance = distance
                    else
                        NearestVehicle = nil
                        NearestVehicleDistance = 0
                    end
                else
                    NearestVehicle = nil
                    NearestVehicleDistance = 0
                end
            end
        end
        Wait(1000)
    end
end)

-- Registreer keybind voor sleutelmenu
RegisterKeyMapping(Config.Commands.toggleLock, 'Vergrendel/Ontgrendel voertuig', 'keyboard', Config.DefaultKeybind)

-- Functie om te controleren of speler sleutels heeft voor een voertuig
function HasVehicleKeys(plate)
    if Config.Debug then
        return true
    end
    
    if HasKeys[plate] then
        return true
    end
    
    -- Controleer of speler een politie/ambulance baan heeft (voor noodvoertuigen)
    if PlayerData.job then
        if PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
            for _, vehicle in pairs(Config.BlacklistedVehicles) do
                if string.find(GetEntityModel(NearestVehicle), vehicle) then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Functie om voertuig te vergrendelen/ontgrendelen
function ToggleVehicleLock()
    if not NearestVehicle or NearestVehicleDistance > Config.LockDistance then
        ShowNotification(Locales['no_vehicle_nearby'])
        return
    end
    
    local plate = GetVehicleNumberPlateText(NearestVehicle):gsub("^%s*(.-)%s*$", "%1")
    
    if HasVehicleKeys(plate) then
        local lockStatus = GetVehicleDoorLockStatus(NearestVehicle)
        
        if lockStatus == 1 or lockStatus == 0 then -- Ontgrendeld
            SetVehicleDoorsLocked(NearestVehicle, 2) -- Vergrendel
            PlayVehicleLockSound(NearestVehicle, 'lock')
            SetVehicleLights(NearestVehicle, 2)
            Wait(250)
            SetVehicleLights(NearestVehicle, 0)
            ShowNotification(Locales['vehicle_locked'])
        else -- Vergrendeld
            SetVehicleDoorsLocked(NearestVehicle, 1) -- Ontgrendel
            PlayVehicleLockSound(NearestVehicle, 'unlock')
            SetVehicleLights(NearestVehicle, 2)
            Wait(250)
            SetVehicleLights(NearestVehicle, 0)
            ShowNotification(Locales['vehicle_unlocked'])
        end
    else
        ShowNotification(Locales['no_keys'])
    end
end

-- Functie om geluid af te spelen bij vergrendelen/ontgrendelen
function PlayVehicleLockSound(vehicle, type)
    local coords = GetEntityCoords(vehicle)
    local sound = Config.Sounds[type]
    
    PlaySoundFromCoord(-1, sound.audioName, coords.x, coords.y, coords.z, sound.audioRef, false, sound.volume, false)
end

-- Functie voor notificaties
function ShowNotification(message, type)
    if Config.NotificationType == 'qbcore' then
        Framework.Functions.Notify(message, type or 'primary')
    elseif Config.NotificationType == 'esx' then
        Framework.ShowNotification(message)
    else
        -- Custom notificatie systeem
        TriggerEvent('vehiclekeys:showNotification', {
            title = Locales['notification_title'],
            description = message,
            type = type or 'info'
        })
    end
end

-- Exporteer functies voor gebruik in andere scripts
exports('HasVehicleKeys', HasVehicleKeys)
exports('GiveVehicleKeys', function(plate)
    HasKeys[plate] = true
    TriggerServerEvent('vehiclekeys:server:AddVehicleKeys', plate)
end)

-- Ontvang sleutels van server
RegisterNetEvent('vehiclekeys:client:AddVehicleKeys', function(plate)
    HasKeys[plate] = true
end)

-- Verwijder sleutels
RegisterNetEvent('vehiclekeys:client:RemoveVehicleKeys', function(plate)
    HasKeys[plate] = nil
end)

-- Ontvang alle sleutels bij inloggen
RegisterNetEvent('vehiclekeys:client:SetVehicleKeys', function(keysList)
    HasKeys = keysList
end)