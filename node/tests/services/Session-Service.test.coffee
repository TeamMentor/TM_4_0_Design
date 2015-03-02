Session_Service = require('../../services/Session-Service')
session         = require('express-session')

describe '| services | Session.test', ()->

  testDb         = './_session_TestDb'
  session_Service = null

  before  ()->
    session_Service = new Session_Service { filename: testDb}
    session_Service.setup()

  after ()->
    testDb.assert_File_Exists()
    testDb.file_Delete().assert_Is_True()

  it 'constructor (no params)',->
    using new Session_Service(),->
      @.filename.assert_Is './.tmCache/_sessionData'


  it 'get,set',  (done)->
    key          = 'session_key'.add_5_Random_Letters()
    session_data = { value: key, expire: new Date() }
    using session_Service,->
      @.set key, session_data,  (err)=>
        assert_Is_Null(err);

        @.get key,  (err, data)->
          assert_Is_Null(err);
          data.assert_Is(session_data)
          done();


  it 'destroy', (done)->
    key          = 'session_key'.add_5_Random_Letters()
    session_data = { value: key, expire: new Date() }

    session_Service.set key, session_data,  (err)->
      assert_Is_Null(err);

      session_Service.get key, (err, data)->
        assert_Is_Null(err);
        data.assert_Is(session_data)

        session_Service.destroy key, (err)->
          assert_Is_Null(err);

          session_Service.get key, (err, data)->
            assert_Is_Null(err);
            assert_Is_Null(data);
            done()


  it 'viewed_Articles', (done)->
    using session_Service,->
      @.set 'sid-1', {recent_Articles: [{id: 'id_1', title: 'title_1'}]}, =>
        @.set 'sid-2', {recent_Articles: [{id: 'id_2', title: 'title_2'}]}, =>
          @.set 'sid-3', {recent_Articles: [{id: 'id_3', title: 'title_3'}]}, =>
            @.set 'sid-4', {recent_Articles: [{id: 'id_4', title: 'title_4'}]}, =>
              @.db.find {}, (err,sessionData)=>
                sessionData.size().assert_Is_Bigger_Than 3
                @.viewed_Articles (data)->
                  data.json_Str().assert_Contains ['id_1','id_2', 'id_3', 'id_4','title_1','title_2', 'title_3', 'title_4']
                  done()

  it 'viewed_Articles (no express session)', (done)->
    using new Session_Service(), ->
      @viewed_Articles (data)->
        data.assert_Is {}
        done()
