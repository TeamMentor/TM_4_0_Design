Express_Service   = null
Jade_Service      = null
Graph_Service     = null
Analytics_Service = null

class Article_Controller

  dependencies: ()->
    Express_Service    = require('../services/Express-Service')
    Jade_Service       = require('../services/Jade-Service')
    Graph_Service      = require('../services/Graph-Service')
    Analytics_Service  = require('../services/Analytics-Service')

  constructor: (req, res, next,graph_Options)->
    @dependencies()
    @.req              = req
    @.res              = res
    @.next             = next
    @.jade_Article     = 'user/article.jade'
    @.jade_Articles    = 'user/articles.jade'
    @.jade_No_Article  = 'user/no-article.jade'
    @.jade_Service     = new Jade_Service();
    @.graphService     = new Graph_Service(graph_Options)

  article: =>
    send_Article = (view_Model)=>
      if view_Model
        @res.send @jade_Service.render_Jade_File(@jade_Article, view_Model)
      else
        @res.send @jade_Service.render_Jade_File(@jade_No_Article)

    article_Ref = @req.params.ref

    @.graphService.article article_Ref, (data)=>

      article_Id = data.article_Id
      if article_Id
        @graphService.node_Data article_Id, (article_Data)=>
           using new Analytics_Service(@.req, @.res), ->
             @.track(article_Data?.title,article_Id)
            title      = article_Data?.title
            technology = article_Data?.technology
            type       = article_Data?.type
            phase       = article_Data?.phase
            @graphService.article_Html article_Id, (data)=>
              @recentArticles_Add article_Id, title
              send_Article { id : article_Id, title: title,  article_Html: data?.html, technology: technology, type: type, phase: phase}
      else
        send_Article null

  articles: =>
    @graphService.articles (articles)=>
      view_Model = { results: articles.values()}
      @res.send @jade_Service.render_Jade_File(@jade_Articles, view_Model)

  check_Guid: =>
    guid = @.req.params?.guid
    if(guid and                                                                       # if we have a value
       guid.split('-').size() is 5 and                                                #   are there are 4 dashes
       guid.size() is 36)                                                             #   and the size if 32
      guid_regex = /^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/i  # use this regex to check if the value provided is a guid
      if guid_regex.test(guid.upper())                                                # if it isa regex
        return @.res.redirect "/article/#{guid}"                                      #   redirect the user back to the /article/:ref route
                                                                                      # if not
    @.next()                                                                          #   continue with the next express route

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

  checkAuth       =  (req,res,next) -> expressService.checkAuth(req, res, next)

  articleController = (method_Name) ->                                                       # pins method_Name value
        return (req, res,next) ->                                                            # returns function for express
            new Article_Controller(req, res, next,graph_Options)[method_Name]()   # creates SearchController object with live

  app.get '/a/:ref'               , checkAuth, articleController('article')
  app.get '/article/:ref/:guid'   , checkAuth, articleController('check_Guid')
  app.get '/article/:ref/:title'  , checkAuth, articleController('article')
  app.get '/article/:ref'         , checkAuth, articleController('article')
  app.get '/articles'             , checkAuth, articleController('articles')
  app.get '/teamMentor/open/:guid', checkAuth, articleController('check_Guid')


module.exports = Article_Controller