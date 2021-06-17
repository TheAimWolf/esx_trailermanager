resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

author 'AimWolf'

description 'Load cars on trailers + manage trailers'

version '1.1.0'

client_scripts {
  '@es_extended/locale.lua',
  'locales/en.lua',
  'locales/de.lua',
  'config.lua',
  'client.lua'
}

server_scripts {
  'server.lua'
}
