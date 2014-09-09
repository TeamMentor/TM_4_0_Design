/*jshint node: true */
"use strict";

function checkAuth(req, res, next) 
{    
    if (!req.session) 
    {
        res.send('You are not authorized to view this page');
    }
    else 
    {
        next();
    }
}

module.exports = checkAuth;