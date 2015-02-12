Article_Controller = require '../../controllers/Article-Controller'
Express_Service    = require '../../services/Express-Service'
Express_Session    = require('../../misc/Express-Session')
app                = require '../../server'
cheerio            = require 'cheerio'

supertest = require 'supertest'

describe '| services | Article-Controller.test', ->
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
        $('.content #oops').html().assert_Is 'Oops'
        $('.content p'    ).html().assert_Is 'That article doesn&apos;t exist.'
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
        $('#article #title').html().assert_Is article_Title
        $('#article #html' ).html().assert_Is article_Html
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

  it 'recentArticles, recentArticles_add', (done)->
    article_Id    = 'id-aaaaaaaa'
    article_Title = 'title-bbbbb'

    req =
      params: id : article_Id
      session: recent_Articles: []

    res = {}

    graphService =
      node_Data   : (id, callback) -> callback {title: article_Title }
      article_Html: (id, callback) -> callback null

    using new Article_Controller(req,res), ->
      @recentArticles().assert_Is []                        # check default value and using recentArticles_Add directly
      @recentArticles_Add 'id_abc','title_123'
      @recentArticles().assert_Is [{'href' : '/article/id_abc', 'title' : 'title_123'}]

      @.graphService = graphService                         # check via (simulated) call to article()
      res.send =  ()=>
        @recentArticles().assert_Size_Is 2
        @recentArticles().first().assert_Is {'href' : "/article/#{article_Id}", 'title' : article_Title}

        @recentArticles_Add 'id_1111','title_1111'          # add another one directly
        @recentArticles().assert_Size_Is 3
        @recentArticles().second().assert_Is {'href' : "/article/#{article_Id}", 'title' : article_Title}

        @recentArticles_Add 'id_2222','title_2222'          # and another one
        @recentArticles().assert_Size_Is 3
        @recentArticles().third().assert_Is {'href' : "/article/#{article_Id}", 'title' : article_Title}

        @recentArticles_Add 'id_3333','title_3333'          # last one so that we have a full set
        @recentArticles().assert_Size_Is 3
        @recentArticles().first() .assert_Is {'href' : '/article/id_3333', 'title' : 'title_3333'}
        @recentArticles().second().assert_Is {'href' : '/article/id_2222', 'title' : 'title_2222'}
        @recentArticles().third() .assert_Is {'href' : '/article/id_1111', 'title' : 'title_1111'}

        done()

      @article()


  describe 'using Express_Service | ',->

    tmpSessionFile = './_tmp_Session'
    app            = null

    before (done)->
      using new Express_Service(),->
        @.add_Session(tmpSessionFile)
        @.loginEnabled = false
        @.app._router.stack.assert_Size_Is 3
        Article_Controller.registerRoutes @.app, @
        @.app._router.stack.assert_Size_Is 4
        app = @.app
        done()

    after ->
      tmpSessionFile.assert_File_Deleted()

    it '/article/:id', (done)->
        supertest(app).get('/article/aaaa')
                      .end (err,res)->
                        res.text.assert_Contains('<a href="/user/main.html">')    # article page ('post login')
                                .assert_Contains('Oops')                          # only exists on the no-article page
                        done()

