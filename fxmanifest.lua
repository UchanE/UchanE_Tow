fx_version 'adamant'

shared_script "@evp/main.lua"

game 'gta5'

client_script {
    "@vrp/client/Tunnel.lua",
    "@vrp/client/Proxy.lua",
    'config.lua',
    'Source/Lua/cl.lua',
}

server_script {
    "@vrp/lib/MySQL.lua",
    '@vrp/lib/utils.lua',
    'config.lua',
    'Source/Lua/sv.lua'
}