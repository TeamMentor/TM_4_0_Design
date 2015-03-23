Express_Service = require('../../src/services/Express-Service')
Session_Service = require('../../src/services/Session-Service')
express         = require('express')
session         = require('express-session')
supertest       = require('supertest')

describe '| services | Express-Service.test', ()->

  it 'constructor',->

    using new Express_Service(),->
      @.app        .assert_Is_Function() # can't seem to have define type(yet)
      @.app.port   .assert_Is_Number()
      @loginEnabled.assert_Is_True()
      assert_Is_Null @.session_Service
      assert_Is_Null @.logging_Service

  it 'setup',->
    using new Express_Service().setup(),->
      @.app.constructor.name.assert_Is 'EventEmitter'
      @.app.port       .assert_Is 1337
      @loginEnabled.assert_Is_True()

      console.log       .assert_Is global.info
      @.logging_Service.assert_Is_Object()
      @.logging_Service.original_Console.assert_Is_Function()
      @.logging_Service.restore_Console()
      console.log       .assert_Is_Not global.info
      console.log       .assert_Is @.logging_Service.original_Console



  describe 'session',->

    expressService = null

    before ->
      expressService = new Express_Service()

    it 'Create temp session file',(done)->
      session_File = './.tmCache/_test_sessionData'
      expressService.add_Session(session_File)
      session_File.file_Delete().assert_Is_True();
      supertest(expressService.app)
        .get '/'
        .end (err,res)->
          using session_File, ->
            @.assert_File_Exists()
            @.file_Contents().assert_Contains('sid')
            @.file_Delete().assert_Is_True();
          done()

    it 'Directly access session data', (done)->
      using expressService.session_Service,->
        @.constructor.name.assert_Is 'Session_Service'
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



  describe 'checkAuth',->
    expressService = null

    before ->
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



