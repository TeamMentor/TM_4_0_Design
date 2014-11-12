/*jshint node: true */
"use strict";
var preCompiler = require(process.cwd() + '/node/services/jade-pre-compiler.js');

function checkAuth(req, res, next)
{
    if (!req.session.username)
    {
        res.status(403).send(preCompiler.renderJadeFile('/source/getting-started/index.jade'));
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