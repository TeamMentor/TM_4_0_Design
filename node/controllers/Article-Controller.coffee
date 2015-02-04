Express_Service  = require('../services/Express-Service')
Jade_Service     = require('../services/Jade-Service')
Graph_Service    = require('../services/Graph-Service')
Config           = require('../misc/Config')

class Article_Controller
  constructor: (req, res, config)->

    @.req          = req;
    @.res          = res;
    @.config       = config || new Config()
    @.jade_Page     = '/source/jade/user/article-new-window-view.jade'
    @.jade_Service = new Jade_Service(@.config);
    @.graphService  = new Graph_Service()

  article: =>
    article_Id = @req.params.id
    @graphService.node_Data article_Id, (article_Data)=>
      @graphService.article_Html article_Id, (article_Html)=>
        view_Model = { id : article_Id, title: article_Data.title, article_Html: article_Html}
        @res.send @jade_Service.renderJadeFile(@jade_Page, view_Model)

Article_Controller.registerRoutes = (app, expressService) ->

  expressService ?= new Express_Service()
  checkAuth       =  (req,res,next) -> expressService.checkAuth(req, res,next, app?.config)

  articleController = (method_Name) ->                                  # pins method_Name value
        return (req, res) ->                                             # returns function for express
            new Article_Controller(req, res, app.config)[method_Name]()    # creates SearchController object with live

  app.get "/article/:id"  , checkAuth, articleController('article')

module.exports = Article_Controller