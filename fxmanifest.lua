fx_version 'cerulean'
game 'gta5'

author 'Trae AI'
description 'Vernieuwd Voertuigsleutels Systeem - Compatibel met QBCore, ESX, en QBOX'
version '1.0.0'

shared_scripts {
    'config.lua',
    'locales/nl.lua',
    'framework/shared.lua'
}

client_scripts {
    'client/main.lua',
    'client/events.lua',
    'client/commands.lua',
    'client/functions.lua'
}

server_scripts {
    'server/main.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/functions.lua'
}

dependency 'qb-core' -- Optioneel, afhankelijk van welk framework je gebruikt