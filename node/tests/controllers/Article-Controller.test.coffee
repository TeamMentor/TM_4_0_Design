Article_Controller = require '../../controllers/Article-Controller'
Express_Service    = require '../../services/Express-Service'
app                = require '../../server'
cheerio            = require 'cheerio'

supertest = require 'supertest'

describe.only '| services | Article-Controller.test', ->
  it 'constructor', (done)->
    using new Article_Controller(), ->
      @.jade_Article.assert_Is    '/source/jade/user/article.jade'
      @.jade_No_Article.assert_Is '/source/jade/user/no-article.jade'
      done()

  it 'article (bad id)', (done)->
    req =
      params: id: 123
      session: recent_Articles: []
    res =
      send : (data)->
        $ = cheerio.load(data)
        $('#content #oops').html().assert_Is 'Oops'
        $('#content p'    ).html().assert_Is 'That article doesn&apos;t exist.'
        done()

    using new Article_Controller(req,res), ->
      @.article()

  it 'article (good id)', (done)->

    article_Id    = 'article-12345'
    article_Title = 'this is an title'
    article_Html  = 'html is here'

    req =
      params: id: article_Id
      session: recent_Articles: []
      
    res =
      send : (data)->
        $ = cheerio.load(data)
        $('#content #title').html().assert_Is article_Title
        $('#content #html' ).html().assert_Is article_Html
        done()

    graphService =
      node_Data: (id, callback)->
        if id is article_Id
          callback { title: article_Title }
      article_Html: (id, callback)->
        if id is article_Id
          callback article_Html

    using new Article_Controller(req,res), ->
      @.graphService = graphService
      @.article()

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
