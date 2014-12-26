/*jslint node: true */
"use strict";

require('coffee-script/register');                      // enabled coffee-script support

var express    = require('express'),
    bodyParser = require('body-parser'),
    app        = express(),
    session    = require('express-session'),
    Config     = require('./Config');

app.config = new Config();
app.use(bodyParser.json()                        );     // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({ extended: true }));     // to support URL-encoded bodies
app.use(session({secret           : '1234567890', 
                 saveUninitialized: true        ,
                 resave           : true        }));
app.register('.html', require('jade'));

require('./routes/flare_routes')(app);
require('./routes/routes')(app);
require('./routes/debug')(app);
require('./routes/config')(app);


app.use(express['static'](process.cwd()));

app.port       = process.env.PORT || 1337;

if        (process.mainModule.filename.indexOf('node_modules/mocha/bin/_mocha'   ) > 0) { console.log('[Running under Mocha]'); }
else if   (process.mainModule.filename.indexOf('node_modules/grunt-cli/bin/grunt') > 0) { console.log('[Running under Grunt]'); }
else
{
    console.log("[Running locallsy or in Azure] Starting 'TM Jade' Poc on port " + app.port);
    app.listen(app.port);
}

module.exports = app;