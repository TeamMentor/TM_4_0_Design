PoC_Controller   = require '../../poc/PoC-Controller'
Express_Service  = require('../../services/Express-Service')
supertest        = require('supertest')

describe '| poc | Controller-PoC.test' ,->
  tmpSessionFile = './_tmp_Session'

  after ->
    tmpSessionFile.assert_File_Deleted()

  it 'constructor',->
    using new PoC_Controller('a','b') ,->
      @.req.assert_Is 'a'
      @.res.assert_Is 'b'

  it 'top-articles', (done)->
    req = {}
    res = {}
    using new PoC_Controller(req, res) ,->
      done()

  it 'Create Express_Service and open /poc', (done)->
    using new Express_Service(),->
      @.add_Session(tmpSessionFile)
      @.loginEnabled = false
      @.app._router.stack.assert_Size_Is 3
      PoC_Controller.register_Routes @.app,@
      @.app._router.stack.assert_Size_Is 5
      supertest(@.app)
        .get('/poc')
        .end (err,res)->
          res.text.assert_Contains 'PoCs'
          done()

