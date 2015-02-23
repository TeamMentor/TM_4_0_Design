Express_Session = require('../../misc/Express-Session')
session         = require('express-session')

describe '| misc | Express-Session.test', ()->
  it 'constructor',->
    using new Express_Session(),->
      @.filename.assert_Is('_session_Data')

  testDb         = './_session_TestDb'
  expressSession = null

  before  ()->
    expressSession = new Express_Session { filename: testDb,session: session }

  after ()->
    testDb.assert_File_Exists()
    testDb.file_Delete().assert_Is_True()

  it 'get,set',  (done)->
    key          = 'session_key'.add_5_Random_Letters()
    session_data = { value: key, expire: new Date() }
    using expressSession,->
      @.set key, session_data,  (err)=>
        assert_Is_Null(err);

        @.get key,  (err, data)->
          assert_Is_Null(err);
          data.assert_Is(session_data)
          done();


  it 'destroy', (done)->
    key          = 'session_key'.add_5_Random_Letters()
    session_data = { value: key, expire: new Date() }

    expressSession.set key, session_data,  (err)->
      assert_Is_Null(err);

    expressSession.get key, (err, data)->
      assert_Is_Null(err);
      data.assert_Is(session_data)

      expressSession.destroy key, (err)->
        assert_Is_Null(err);

        expressSession.get key, (err, data)->
          assert_Is_Null(err);
          assert_Is_Null(data);
          done()


