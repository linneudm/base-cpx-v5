fx_version "bodacious"
game "gta5"
lua54 "yes"

author "bkvini.ofc1"
description "Recurso desenvolvido com base e suporte da FiveCommunity"

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
