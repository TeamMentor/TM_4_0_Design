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

function mappedAuth(req) 
{    
    //console.log('HERE: ' + JSON.stringify(req.session));
    return {
                username : req.session.username,
                loggedIn : (req.session.username !== undefined)
           };    
}


module.exports = { 
                    checkAuth : checkAuth,
                    mappedAuth : mappedAuth
                 };