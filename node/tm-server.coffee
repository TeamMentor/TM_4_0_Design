require 'fluentnode'

Logging_Service = require('./services/Logging-Service')
Express_Service = require('./services/Express-Service')

new Logging_Service().setup()

logger?.info('[TM-Server] Log is setup')

global.info = console.log                   # legacy, global.info calls need to be changed to logger?.info

info('Configuring TM_Design Express server')

expressService = new Express_Service()

using expressService,->
    @.setup()
    @.start()

module.exports = expressService.app