Config = {}

-- Framework instellingen
Config.Framework = 'qbcore' -- 'qbcore', 'esx', 'qbox', 'ox'

-- Algemene instellingen
Config.UseItemKeys = true -- true = item-gebaseerde sleutels, false = speler-identifier sleutels
Config.DefaultKeybind = 'L' -- Standaard toets voor sleutelmenu
Config.LockDistance = 10.0 -- Maximale afstand om een voertuig te vergrendelen/ontgrendelen
Config.HotwireTime = 10 -- Tijd in seconden om een voertuig te hotwiren
Config.LockpickTime = 15 -- Tijd in seconden om een voertuig te lockpicken
Config.LockpickBreakChance = 50 -- Kans dat lockpick breekt (0-100%)

-- Voertuig instellingen
Config.BlacklistedVehicles = { -- Voertuigen die niet vergrendeld/ontgrendeld kunnen worden
    'police', 
    'police2',
    'police3',
    'ambulance'
}

-- Item instellingen (alleen als UseItemKeys = true)
Config.KeyItem = 'vehicle_key' -- Naam van het sleutelitem
Config.LockpickItem = 'lockpick' -- Naam van het lockpick item
Config.AdvancedLockpickItem = 'advancedlockpick' -- Naam van het geavanceerde lockpick item

-- Notificatie instellingen
Config.NotificationType = 'qbcore' -- 'qbcore', 'esx', 'custom'

-- Geluid instellingen
Config.Sounds = {
    lock = {
        audioName = "Remote_Control_Close",
        audioRef = "PI_MENU_SOUNDS",
        volume = 0.5
    },
    unlock = {
        audioName = "Remote_Control_Open",
        audioRef = "PI_MENU_SOUNDS",
        volume = 0.5
    },
    hotwire = {
        audioName = "Hotwire",
        audioRef = "DLC_PILOT_MP_HUD_SOUNDS",
        volume = 0.5
    },
    lockpick = {
        audioName = "VEHICLES_DOOR_OPEN",
        audioRef = "VEHICLES_DOOROPEN",
        volume = 0.5
    }
}

-- Commando instellingen
Config.Commands = {
    toggleLock = 'sleutel', -- Commando om voertuig te vergrendelen/ontgrendelen
    giveKeys = 'geefsleutel', -- Commando om sleutels te geven aan een andere speler
    addKeys = 'voegsleuteltoe', -- Admin commando om sleutels toe te voegen
    removeKeys = 'verwijdersleutel' -- Admin commando om sleutels te verwijderen
}

-- Debug modus
Config.Debug = false -- Debug modus aan/uit