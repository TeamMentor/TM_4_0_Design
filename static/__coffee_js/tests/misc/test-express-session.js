/*jslint node: true */
/*global describe, it, before */
"use strict";

var express = require('express'),
    session    = require('express-session'),
    request = require('supertest');


describe('test-express-session', function ()
{
    var app = express();
    
    var testValue     = 'this is a session value';
    var sessionAsJson = '{"cookie":{"originalMaxAge":null,"expires":null,"httpOnly":true,"path":"/"}}';        
    
    before(function() 
    {
        //recrete the config used on server.js and add a couple test routes
        app.use(session({secret           : '1234567890', 
                         saveUninitialized: true        ,
                         resave           : true        }));

        var middleware = function(req,res,next)
        {
            req.session.value = testValue;
            next();
        };        
        app.get('/session_values'     ,             function (req,res)  { res.send(req.session);});        
        app.get('/session_get_userId' , middleware, function (req,res)  { res.send(req.session.value);});
    });
    
    it('Check default session values', function(done)
    {        
        request(app).get('/session_values')                    
                    .expect(200,sessionAsJson, done);        
    });
    
    it('Check specific session value', function(done)
    {        
        request(app).get('/session_get_userId')                    
                    .expect(200,testValue, done);        
    });
});