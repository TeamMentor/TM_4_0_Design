/*jslint node: true */
"use strict";
var util = require('util');

module.exports = function (app) 
{    
    app.get('/module'    , function(req,res)  { res.send( '<pre>' + util.inspect(module)              + '</pre>'); });
    app.get('/mainModule', function(req,res)  { res.send( '<pre>' + util.inspect(process.mainModule)  + '</pre>'); });    
    app.get('/session'   , function(req,res)  { res.send(req.session          ); } );
    
    app.get('/dirName'   , function(req,res)  { res.send(__dirname            ); } );
    app.get('/pwd'       , function(req,res)  { res.send(process.cwd()        ); } );    
    app.get('/test'      , function(req,res)  { res.send('from routes.js..'   ); } );
    app.get('/ping'      , function(req,res)  { res.send('pong..'             ); } );    
};
