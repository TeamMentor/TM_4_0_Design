Express_Service = require('../../services/Express-Service')
express = require('express')
session = require('express-session')
request = require('supertest')

describe 'services | Express-Service.test', ()->
  it 'constructor',->
    using new Express_Service(),->
      @loginEnabled.assert_Is_True()

  it 'test exports',->
    Express_Service.assert_Is_Function()
    using new Express_Service(),->
      @.checkAuth.assert_Is_Function()
      @.mappedAuth.assert_Is_Function()

  describe 'auth',->
    expressService = new Express_Service()

    it 'checkAuth (all null)', (done)->
      expressService.checkAuth(null,null, done,null)

    it 'checkAuth (valid session username)', (done)->
      next = ()->
        done()
      req = { session: { username: 'abc'} }
      expressService.checkAuth(req,null, next,null)

    it 'checkAuth (no session username)', (done)->

      send = (html)->
        html.assert_Contains('You need to login to see that page :)')
        done()
      res = {}
      res.status = (value)->
        value.assert_Is(403)
        res
      res.send   = send
      config = null
      req = { session: { username: undefined} }
      expressService.checkAuth(req,res, null,config)



  describe 'testing behaviour of express-session', ()->

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
