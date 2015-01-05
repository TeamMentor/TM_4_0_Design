express = require('express')
session = require('express-session')
request = require('supertest')


describe 'misc | express-session.test', ()->

    app = express()
    
    testValue     = 'this is a session value';
    sessionAsJson = '{"cookie":{"originalMaxAge":null,"expires":null,"httpOnly":true,"path":"/"}}';

    #recrete the config used on server.js and add a couple test routes
    before ()->
        options =
                    secret           : '1234567890'
                    saveUninitialized: true
                    resave           : true

        app.use session(options)

        middleware = (req,res,next)->
            req.session.value = testValue;
            next()
        app.get '/session_values'     ,              (req,res)->  res.send req.session
        app.get '/session_get_userId' , middleware,  (req,res)->  res.send req.session.value
    
    it 'Check default session values', (done)->
        request(app).get '/session_values'
                    .expect 200,sessionAsJson, done
    
    it 'Check specific session value', (done)->
        request(app).get '/session_get_userId'
                    .expect 200,testValue, done
