# Vernieuwd Voertuigsleutels Systeem

## Overview
A comprehensive vehicle key management system for FiveM servers, compatible with multiple frameworks including QBCore, ESX, and QBOX. This resource provides a complete solution for managing vehicle keys, locking/unlocking vehicles, hotwiring, lockpicking, and more.

## Features
- **Multi-Framework Support**: Compatible with QBCore, ESX, and QBOX frameworks
- **Dual Key System**: Choose between item-based keys or player-identifier based keys
- **Vehicle Security**: Lock/unlock vehicles, toggle engine, prevent unauthorized access
- **Advanced Features**: Hotwiring, lockpicking with configurable success rates
- **Key Management**: Give keys to other players, admin commands for key management
- **Blacklist System**: Prevent certain vehicles from being locked/unlocked
- **Fully Configurable**: Extensive configuration options
- **Dutch Localization**: Complete Dutch language support

## Installation
1. Download the resource
2. Place it in your server's resources folder
3. Add `ensure vehiclekeys` to your server.cfg
4. Configure the `config.lua` file to match your server's needs
5. Restart your server

## Configuration
The resource is highly configurable through the `config.lua` file:

### Framework Selection
```lua
Config.Framework = 'qbcore' -- Options: 'qbcore', 'esx', 'qbox', 'ox'
```

### Key System
```lua
Config.UseItemKeys = true -- true = item-based keys, false = player-identifier keys
```

### General Settings
```lua
Config.DefaultKeybind = 'L' -- Default key for vehicle key menu
Config.LockDistance = 10.0 -- Maximum distance to lock/unlock a vehicle
Config.HotwireTime = 10 -- Time in seconds to hotwire a vehicle
Config.LockpickTime = 15 -- Time in seconds to lockpick a vehicle
Config.LockpickBreakChance = 50 -- Chance that lockpick breaks (0-100%)
```

### Vehicle Blacklist
```lua
Config.BlacklistedVehicles = { -- Vehicles that cannot be locked/unlocked
    'police', 
    'police2',
    'police3',
    'ambulance'
}
```

### Item Settings
```lua
Config.KeyItem = 'vehicle_key' -- Name of the key item
Config.LockpickItem = 'lockpick' -- Name of the lockpick item
Config.AdvancedLockpickItem = 'advancedlockpick' -- Name of the advanced lockpick item
```

## Commands
The resource provides several commands for players and administrators:

| Command | Description | Usage |
|---------|-------------|-------|
| /sleutel | Lock/unlock a vehicle | `/sleutel` |
| /geefsleutel | Give keys to another player | `/geefsleutel [player-id]` |
| /voegsleuteltoe | Admin command to add keys | `/voegsleuteltoe [player-id] [plate]` |
| /verwijdersleutel | Admin command to remove keys | `/verwijdersleutel [player-id] [plate]` |

## Usage Examples

### Locking/Unlocking Vehicles
Players can lock or unlock their vehicles by:
- Using the `/sleutel` command
- Pressing the configured keybind (default: L)
- Using the vehicle key menu

### Giving Keys to Other Players
Vehicle owners can give keys to other players by:
- Using the `/geefsleutel [player-id]` command
- Using the "Give Keys" option in the vehicle key menu

### Hotwiring Vehicles
Players without keys can attempt to hotwire vehicles. The success depends on the configured settings and takes time to complete.

### Lockpicking Vehicles
Players can use lockpick items to attempt to unlock vehicles they don't have keys for. There's a configurable chance the lockpick will break during the attempt.

## Dependencies
- A compatible framework (QBCore, ESX, or QBOX)

## Credits
- Created by Trae AI
- Version 1.0.0