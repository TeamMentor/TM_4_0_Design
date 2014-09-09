/*jshint node: true */
"use strict";

function checkAuth(req, res, next) 
{    
    if (!req.session.username) 
    {
        res.status(403).render('../source/html/landing-pages/need-login.jade');
        //res.send('You are not authorized to view this page');
    }
    else 
    {
        next();
    }
}

module.exports = checkAuth;