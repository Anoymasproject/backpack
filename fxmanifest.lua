fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Backpack for Ox Inventory'
version '0.0.1'

client_scripts {
    'client/**.lua'
}

server_scripts {
  'server/server.lua'
}

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

dependencies {
  'ox_inventory'
}
