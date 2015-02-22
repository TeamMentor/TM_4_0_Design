Search_Controller_PoC = require '../../poc/Search-Controller.PoC'
Express_Service       = require('../../services/Express-Service')
supertest             = require('supertest')

describe '| poc | Search-Controller.PoC.test' ,->
  tmpSessionFile = './_tmp_Session'

  after ->
    tmpSessionFile.assert_File_Deleted()

  it 'constructor',->
    using new Search_Controller_PoC('a','b') ,->
      @.req.assert_Is 'a'
      @.res.assert_Is 'b'

  it 'Create Express_Service and open /poc', (done)->
    using new Express_Service(),->
      @.add_Session(tmpSessionFile)
      @.loginEnabled = false
      @.app._router.stack.assert_Size_Is 3
      Search_Controller_PoC.registerRoutes @.app,@
      @.app._router.stack.assert_Size_Is 4
      supertest(@.app)
        .get('/poc')
        .end (err,res)->
          res.text.assert_Contains 'PoCs'
          done()

