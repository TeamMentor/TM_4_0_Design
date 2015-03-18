require 'fluentnode'

Express_Service = require('./services/Express-Service')

expressService = new Express_Service()



using expressService,->
    @.setup()
    @.start()

module.exports = expressService