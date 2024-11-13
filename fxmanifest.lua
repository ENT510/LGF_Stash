fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

name 'LGF Stash'
author 'ENT510'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'Modules/shared/config.lua',
    'Modules/shared/shared.lua',
}

client_scripts {
    'Modules/client/utils.lua',
    'Modules/client/client.lua',
    'Modules/client/shop.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'Modules/server/functions.lua',
    'Modules/server/server.lua',
    'Modules/server/callback.lua',
    'Modules/server/commands.lua',
}
