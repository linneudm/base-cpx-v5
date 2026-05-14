fx_version 'adamant'
game 'gta5'
lua54 "yes"

author 'bkvini'
description 'Sistema de Portas e Gerenciador de Trancas Avançado'
version '2.0.0'

client_scripts {
	"@vrp/lib/utils.lua",
	"client-side/*"
}
shared_scripts {
	"config.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
	"server-side/*"
}

files {
	"web-side/*"
}

ui_page 'web-side/index.html'