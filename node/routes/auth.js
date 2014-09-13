/*jshint node: true */
"use strict";
var preCompiler = require(process.cwd() + '/node/services/jade-pre-compiler.js');

function checkAuth(req, res, next) 
{    
    if (!req.session.username) 
    {
        res.status(403).send(preCompiler.renderJadeFile('/source/html/landing-pages/need-login.jade'));        
    }
    else 
    {
        next();
    }
}

function mappedAuth(req) 
{        
    return {
                username  : req.session.username,
                loggedIn  : (req.session.username !== undefined),
           };    
}

module.exports = { 
                    checkAuth : checkAuth,
                    mappedAuth : mappedAuth
                 };