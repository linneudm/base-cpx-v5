fx_version "bodacious"
game "gta5"
lua54 "yes"

author "bkvini.ofc1"
description "Sistema desenvolvido e configurado por bkvini.ofc1"

ui_page "web-side/index.html"

client_scripts {
    "@vrp/config/Native.lua",
    "@PolyZone/client.lua",
    "@vrp/lib/Utils.lua",
    "client-side/*"
}

server_scripts {
    "@vrp/lib/Utils.lua",
    "server-side/*"
}

shared_scripts {
    "@vrp/config/Item.lua",
    "@vrp/config/Vehicle.lua",
    "@vrp/config/Global.lua",
    "@vrp/config/Drops.lua"
}

files {
    "web-side/*",
    "web-side/**/*"
}

escrow_ignore {
    "server-side/core.lua"
}
