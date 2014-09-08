/*jslint node: true */
"use strict";

var express    = require('express'),
    bodyParser = require('body-parser');

var app      = express();
app.use(bodyParser.json()                        );     // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({ extended: true }));     // to support URL-encoded bodies
//require('./routes/routes.js')(app);
//require('./routes/user.js')(app);

app.use('/',function(req,res) { res.send('simple azure test');});
//app.use(express['static'](process.cwd()));


app.port       = process.env.PORT || 1337;

if (process.mainModule === module)                                  // with this express will not start when this script is loaded from a UnitTest
{
    console.log("Starting 'TM Jade' Poc on port " + app.port);
    app.listen(app.port);
}

module.exports = app;