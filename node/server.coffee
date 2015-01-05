
bodyParser      = require('body-parser')

Logger          = require('./services/Logger-Service')
Express_Service = require('./services/Express-Service')

global.info = new Logger().setup().log

#console.log = global.info
info('Starting Express server config')

expressService = new Express_Service()

app = expressService.app


app.use(bodyParser.json()                        );     # to support JSON-encoded bodies
app.use(bodyParser.urlencoded({ extended: true }));     # to support URL-encoded bodies


expressService.setup()

require('./routes/flare_routes')(app);
require('./routes/routes')(app);
require('./routes/debug')(app);
require('./routes/config')(app);

app.port       = process.env.PORT || 1337;

if process.mainModule.filename.not_Contains('node_modules/mocha/bin/_mocha')
    console.log("[Running locally or in Azure] Starting 'TM Jade' Poc on port " + app.port)
    app.server = app.listen(app.port)

module.exports = expressService.app;