/*jshint node: true */
"use strict";
//var preCompiler = require(process.cwd() + '/node/services/jade-pre-compiler.js');
var Jade_Service        = require('../services/Jade-Service'),
    loginEnabled = true;

function checkAuth(req, res, next) 
{    
    //console.log('Check auth');
    if (loginEnabled && !req.session.username) 
    {
        res.status(403) 
           .send(new Jade_Service().renderJadeFile('/source/html/landing-pages/need-login.jade'));        
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