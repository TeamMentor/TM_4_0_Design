Article_Controller = require '../../controllers/Article-Controller'
Express_Service    = require('../../services/Express-Service')
app                = require('../../server')

supertest = require 'supertest'

describe '| services | Article-Controller.test', ->
  it 'constructor', (done)->
    using new Article_Controller(), ->
      @.jade_Page.assert_Is '/source/jade/user/article-new-window-view.jade'
      done()

  xdescribe 'using Express_Service | ',->

    tmpSessionFile = './_tmp_Session'

    after ->
      tmpSessionFile.assert_File_Deleted()

    it 'Create Express_Service and register Article_Controller routes', (done)->
      using new Express_Service(),->
        @.add_Session(tmpSessionFile)
        @.loginEnabled = false
        @.app._router.stack.assert_Size_Is 3
        Article_Controller.registerRoutes @.app
        @.app._router.stack.assert_Size_Is 4
        supertest(@.app)
          .get('/article/aaaa')
          .end (err,res)->
            res.text.assert_Contains('<a href="/user/main.html">')
                    .assert_Contains('Search')
            done()
