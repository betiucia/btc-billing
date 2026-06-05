fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'btc-billing'
version '1.0.0'
author 'Betiucia Scripts'

shared_scripts {
	'locale.lua',
	'config/*.lua'
}

client_scripts {
	'client/modules/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/int.lua',
	'server/server.lua',
	'server/webhook.lua',
	'server/versionchecker.lua',
	'server/modules/*.lua',
}

dependencies {
	'btc-core',
}


escrow_ignore {
	'locale.lua',
	'config/*.lua'
}


lua54 'yes'
