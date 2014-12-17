/*jshint node: true */
"use strict";
//var preCompiler = require(process.cwd() + '/node/services/jade-pre-compiler.js');
var Jade_Service        = require('../services/Jade-Service'), 
    loginEnabled = true;

function checkAuth(req, res, next, config) 
{        
    if(config && config.disableAuth) 
    {
        next();
        return;
    }    
    if (loginEnabled && !req.session.username) 
    {        
        res.status(403) 
           .send(new Jade_Service(config).renderJadeFile('/source/jade/guest/login-required.jade'));
    }
    else 
    {
        next();
    }
}

function mappedAuth(req) 
{   
    var data = {};
    if(req && req.session)
        data =  {
                    username  : req.session.username,
                    loggedIn  : (req.session.username !== undefined),
                };    
    return data;
}

module.exports = { 
                    checkAuth : checkAuth,
                    mappedAuth : mappedAuth
                 };