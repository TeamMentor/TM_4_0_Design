Express_Service = require('../../services/Express-Service')
Express_Session = require('../../misc/Express-Session')
express  = require('express')
session  = require('express-session')
supertest = require('supertest')

describe 'services | Express-Service.test', ()->
  it 'constructor',->
    using new Express_Service(),->
      @.app        .assert_Is_Function() # can't seem to have define type(yet)
      @.app.port   .assert_Is_Number()
      @loginEnabled.assert_Is_True()
      assert_Is_Null(@.expressSession)

  it 'test exports',->
    Express_Service.assert_Is_Function()
    using new Express_Service(),->
      @.checkAuth.assert_Is_Function()
      @.mappedAuth.assert_Is_Function()

  describe 'session',->
    expressService = new Express_Service()

    it 'test',(done)->
      expressService.setup()
      file = './.tmCache/_sessionData'
      file.file_Delete().assert_Is_True();
      supertest(expressService.app)
        .get '/'
        .end (err,res)->
          file.assert_File_Exists()
          file.file_Contents().assert_Contains('sid')
          file.file_Delete().assert_Is_True();
          done()

    it 'Directly access session data', (done)->
      using expressService.expressSession,->
        @.constructor.name.assert_Is 'Express_Session'
        @.db.constructor.name.assert_Is 'Datastore'

        @.db.find {},  (err, docs) ->
          assert_Is_Null err
          docs.assert_Size_Is(1)
          using docs.first(),->
            @.sid.assert_Is_String()
            @._id.assert_Is_String()
            @.data.assert_Is_Object()

            using @.data.cookie,->
              @.path.assert_Is '/'
              @._expires.assert_Instance_Of(Date)
              @.originalMaxAge.assert_Bigger_Than 3153600000
              @.httpOnly.assert_Is_True()

              done()

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
        html.assert_Contains('You need to login to see that page.')
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
      supertest(app).get '/session_values'
                    .expect 200,sessionAsJson, done

    it 'Check specific session value', (done)->
      supertest(app).get '/session_get_userId'
                    .expect 200,testValue, done

  describe 'methods |',->
    it 'viewedArticles', (done)->
      using new Express_Service(), ->
        @.expressSession = new Express_Session()
        @.expressSession.set 'sid-1', {recent_Articles: [{id: 'id_1', title: 'title_1'}]}, =>
          @.expressSession.set 'sid-2', {recent_Articles: [{id: 'id_2', title: 'title_2'}]}, =>
            @.expressSession.set 'sid-3', {recent_Articles: [{id: 'id_3', title: 'title_3'}]}, =>
              @.expressSession.set 'sid-4', {recent_Articles: [{id: 'id_4', title: 'title_4'}]}, =>
                @.expressSession.db.find {}, (err,sessionData)=>
                  @viewedArticles (data)->
                    data.json_Str().assert_Contains ['id_1','id_2', 'id_3', 'id_4','title_1','title_2', 'title_3', 'title_4']
                    done()
