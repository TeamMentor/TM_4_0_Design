Express_Service  = null
Jade_Service     = null
Graph_Service    = null
Config           = null

class Article_Controller

  dependencies: ()->
    Express_Service  = require('../services/Express-Service')
    Jade_Service     = require('../services/Jade-Service')
    Graph_Service    = require('../services/Graph-Service')
    Config           = require('../misc/Config')

  constructor: (req, res, config,graph_Options)->
    @dependencies()
    @.req              = req;
    @.res              = res;
    @.config           = config || new Config()
    @.jade_Article     = '/source/jade/user/article.jade'
    @.jade_Articles    = '/source/jade/user/articles.jade'
    @.jade_No_Article  = '/source/jade/user/no-article.jade'
    @.jade_Service     = new Jade_Service(@.config);
    @.graphService     = new Graph_Service(graph_Options)

  article: =>
    send_Article = (view_Model)=>
      if view_Model
        @res.send @jade_Service.renderJadeFile(@jade_Article, view_Model)
      else
        @res.send @jade_Service.renderJadeFile(@jade_No_Article)

    article_Ref = @req.params.ref

    @.graphService.article article_Ref, (data)=>
      article_Id = data.article_Id
      if article_Id
        @graphService.node_Data article_Id, (article_Data)=>
            title      = article_Data?.title
            technology = article_Data?.technology
            type       = article_Data?.type
            @graphService.article_Html article_Id, (data)=>
              @recentArticles_Add article_Id, title
              send_Article { id : article_Id, title: title,  article_Html: data?.html, technology: technology, type: type}
      else
        send_Article null

  articles: =>
    @graphService.articles (articles)=>
      view_Model = { results: articles.values()}
      @res.send @jade_Service.renderJadeFile(@jade_Articles, view_Model)

  recentArticles: =>
    @.req.session ?= {}
    @.req.session.recent_Articles ?= []
    recentArticles = []
    for recentArticle in @.req.session.recent_Articles.take(3)
        recentArticles.push({href : "/article/#{recentArticle.id}" , title:recentArticle.title})
    recentArticles

  recentArticles_Add: (id, title)=>

    logger?.info {user: @.req.session?.username, action:'view-article', id: id  , title: title}

    @.req.session.recent_Articles ?= []
    @.req.session.recent_Articles.unshift { id: id , title:title}

Article_Controller.register_Routes = (app, expressService,graph_Options) ->

  checkAuth       =  (req,res,next) -> expressService.checkAuth(req, res, next, app?.config)

  articleController = (method_Name) ->                                  # pins method_Name value
        return (req, res) ->                                             # returns function for express
            new Article_Controller(req, res, app.config,graph_Options)[method_Name]()    # creates SearchController object with live


  app.get "/article/:ref/:title", checkAuth, articleController('article')
  app.get "/article/:ref"       , checkAuth, articleController('article')
  app.get "/articles"           , checkAuth, articleController('articles')

module.exports = Article_Controller