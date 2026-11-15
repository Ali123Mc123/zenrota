local config = require 'config.config_s'
local cconfig = require 'config.config_c'

lib.locale(cconfig.language ~= 'auto' and cconfig.language or nil)

SetConvarReplicated('ox:printlevel:' .. cache.resource, config.debug and 'debug' or 'info')

require 'server.callbacks'
require 'server.events'
require 'server.exports'

if cconfig.boxingRing.enable then
    require 'server.boxing_ring'
end
