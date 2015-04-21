Article_Controller = null
Express_Service    = null
Session_Service    = null
cheerio            = null
supertest          = null

describe '| controllers | Article-Controller.test', ->

  dependencies = ->
    Article_Controller = require '../../src/controllers/Article-Controller'
    Express_Service    = require '../../src/services/Express-Service'
    Session_Service    = require('../../src/services/Session-Service')
    cheerio            = require 'cheerio'
    supertest          = require 'supertest'

  before ->
    dependencies()

  it 'constructor', (done)->
    using new Article_Controller(), ->
      @.jade_Article.assert_Is    '/source/jade/user/article.jade'
      @.jade_No_Article.assert_Is '/source/jade/user/no-article.jade'
      done()

  it 'article (bad id)', (done)->
    req =
      params: ref: 123
      session: recent_Articles: []
    res =
      send : (data)->
        $ = cheerio.load(data)
        $('#article #oops').html().assert_Is 'Oops'
        $('#article p'    ).html().assert_Is 'That article doesn&apos;t exist.'
        done()

    using new Article_Controller(req,res), ->
      @.article()

  it 'article (good id)', (done)->

    article_Id    = 'article-12345'
    article_Title = 'this is an title'
    article_Text  = 'html is here '
    article_Html  = 'html is here <pre> var a =12 </pre>'

    req =
      params: ref: article_Id
      session: recent_Articles: []

    res =
      send : (data)->
        $ = cheerio.load(data)

        $('#article #title').html().assert_Is article_Title
        html = $('#article #html' ).html().assert_Contains article_Text
                                          .assert_Contains('<pre> <span class="keyword">')
        $.html().assert_Contains('<link href="/static/css/syntax-highlighting-github-style.css" rel="stylesheet">')
        done()

    graphService =
      article:  (id, callback)->
        if id is article_Id
          callback { article_Id: id }
      node_Data: (id, callback)->
        if id is article_Id
          callback { title: article_Title }
      article_Html: (id, callback)->
        if id is article_Id
          callback { html: article_Html }

    using new Article_Controller(req,res), ->
      @.graphService = graphService
      @.article()

  # this test doesn't work on Travis since the article-8be858175e32 doesn't exist in there, so the highlight check was added to the
  # 'article (good id)' test (above)

  xit 'article (verify syntax highlighting)', (done)->

    article_Id    = 'article-8be858175e32'

    req =
      params: ref: article_Id
      session: recent_Articles: []

    res =
      send : (html)->
        $ = cheerio.load(html)
        $.html().assert_Contains('<pre><span class="keyword">')
        $.html().assert_Contains('<link href="/static/css/syntax-highlighting-github-style.css" rel="stylesheet">')
        done()

    using new Article_Controller(req,res), ->
      @.article()

  it 'articles', (done)->

    article_Id      = 'article-12345'
    article_Title   = 'this is an title'
    article_Summary = 'html summary is here'

    req =

    res =
      send : (data)->
        $ = cheerio.load(data)
        $('#articles').html()
        $('#articles').html().assert_Contains 'list-view-article'
        $('#articles #list-view-article a').attr().assert_Is { href: '/article/12345/this-is-an-title', id: 'article-12345' }
        $('#articles #list-view-article a h4').html().assert_Is 'this is an title'
        $('#articles #list-view-article p').html().assert_Is 'html summary is here...'
        done()

    graphService =
      articles: (callback)->
        callback { article_Id: {
                    guid    : "00000000-0000-0000-0000-000000026eca",
                    title   : article_Title
                    summary : article_Summary
                    is      : "Article",
                    id      : article_Id
                  }}

    using new Article_Controller(req,res), ->
      @.graphService = graphService
      @.articles()

  it 'recentArticles, recentArticles_add', (done)->
    article_Id    = 'id-aaaaaaaa'
    article_Title = 'title-bbbbb'

    req =
      params: id : article_Id
      session: recent_Articles: []

    res = {}

    graphService =
      article     : (id, callback) -> callback {article_Id: article_Id }
      node_Data   : (id, callback) -> callback {title     : article_Title }
      article_Html: (id, callback) -> callback {html      : null }

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


  describe 'routes |',->

    before ->
      dependencies()

    it 'register_Routes',->
      route_Inner_Code = 'new Article_Controller(req, res, app.config, graph_Options)[method_Name]();'
      routes = {}
      app    =
        get: (url, checkAuth,target)->
          checkAuth.assert_Is_Function()
          routes[url] = target

      Article_Controller.register_Routes app
      routes.keys().assert_Is [ '/article/:ref/:title','/article/:ref', '/articles' ]
      routes['/article/:ref/:title'].source_Code().assert_Contains route_Inner_Code
      routes['/article/:ref'       ].source_Code().assert_Contains route_Inner_Code
      routes['/articles'           ].source_Code().assert_Contains route_Inner_Code
