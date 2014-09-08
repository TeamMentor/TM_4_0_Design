/*jslint node: true */
"use strict";

var express    = require('express'),
    bodyParser = require('body-parser'),
    app        = express();

app.use(bodyParser.json()                        );     // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({ extended: true }));     // to support URL-encoded bodies

require('./routes/routes.js')(app);
require('./routes/user.js')(app);

app.use(express['static'](process.cwd()));

app.port       = process.env.PORT || 1337;

if        (process.mainModule.filename.indexOf('node_modules/mocha/bin/_mocha') > 0)   { console.log('[Running under Mocha]'); }
else if   (process.mainModule.filename.indexOf('interceptor.js'               ) > 0)   { console.log('[Running under Azure]'); }
else
{
    console.log("[Running locally] Starting 'TM Jade' Poc on port " + app.port);
    app.listen(app.port);
}
    
module.exports = app;