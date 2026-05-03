-- shared_script "lib/lib.lua"

fx_version "bodacious"
game "gta5"
lua54 "yes"

ui_page "gui/index.html"

client_scripts {
	"config/Vehicles.lua",
	"config/Global.lua",
	"config/Item.lua",
	"config/Native.lua",
	"lib/utils.lua",
	"client/*"
}

server_scripts {
	"config/Vehicles.lua",
	"config/Item.lua",
	"lib/utils.lua",
	"modules/*"
}

files {
	"lib/*",
	"gui/*",
	"loading/*",
}

loadscreen "loading/index.html"
