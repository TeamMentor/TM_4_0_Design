require 'fluentnode'
console.time('at-server')
#Logger          = require('./services/Logger-Service')
Express_Service = require('./services/Express-Service')

#global.info     = new Logger().setup().log

#console.log = global.info

global.info = console.log
asd.asd()
info('Configuring TM_Design Express server')

expressService = new Express_Service()

using expressService,->
    @.setup()
    @.start()

module.exports = expressService.app