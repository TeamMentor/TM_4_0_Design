/*jslint node: true */
"use strict";

var express    = require('express'),
    bodyParser = require('body-parser'),
    app        = express(),
    session    = require('express-session');

app.use(bodyParser.json()                        );     // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({ extended: true }));     // to support URL-encoded bodies
app.use(session({secret           : '1234567890', 
                 saveUninitialized: true        ,
                 resave           : true        }));


//require('./routes/help.js' )(app);
require('./routes/routes.js')(app);
//require('./routes/user.js'  )(app);
require('./routes/debug.js' )(app);


app.use(express['static'](process.cwd()));

app.port       = process.env.PORT || 1337;

if        (process.mainModule.filename.indexOf('node_modules/mocha/bin/_mocha') > 0)   { console.log('[Running under Mocha]'); }
//else if   (process.mainModule.filename.indexOf('interceptor.js'               ) > 0)   { console.log('[Running under Azure]'); }
else
{
    console.log("[Running locally or in Azure] Starting 'TM Jade' Poc on port " + app.port);
    app.listen(app.port);
}
    
module.exports = app;