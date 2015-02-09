Logger          = require('./services/Logger-Service')
Express_Service = require('./services/Express-Service')

global.info = new Logger().setup().log

#console.log = global.info
info('Starting Express server config')

expressService = new Express_Service()

using expressService,->
    @.setup()
    @.map_Route('../routes/flare_routes')
    @.map_Route('../routes/routes')
    @.start()

module.exports = expressService.app