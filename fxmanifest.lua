description 'moro_catapult'
author 'Morojgovany'
fx_version "adamant"
games { "rdr3" }
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
startup_message "moro_catapult loaded successfully!"

server_script {
    'server.lua'
}

shared_scripts {
    'config.lua',
}

client_script {
    'client.lua'
}
