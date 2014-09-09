/*jshint node: true */
"use strict";

function checkAuth(req, res, next) 
{    
    if (!req.session.username) 
    {
        res.status(403).render('../source/html/landing-pages/need-login.jade');        
    }
    else 
    {
        next();
    }
}

module.exports = checkAuth;