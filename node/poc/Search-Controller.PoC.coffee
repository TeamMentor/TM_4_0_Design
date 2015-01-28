Config          = require('../misc/Config')
Express_Service = require('../services/Express-Service')
Jade_Service    = require('../services/Jade-Service')
Graph_Service   = require('../services/Graph-Service')

class Search_Controller_PoC

    constructor: (req, res, config)->
        @req                = req
        @res                = res

        @jade_Service       = new Jade_Service()
        @graphService       = new Graph_Service()


    poc_Search_Two_Column: =>
      target = @.req.query.text
      jade_Page = '/source/jade/-poc-/search/two-columns.jade'
      @graphService.query_From_Text_Search target,  (query_Id)=>
        @graphService.graphDataFromGraphDB null, query_Id, null,  (searchData)=>
          searchData.text = @.req.query.text
          html = @jade_Service.renderJadeFile(jade_Page, searchData)
          @res.send html


Search_Controller_PoC.registerRoutes = (app, expressService) ->

    expressService ?= new Express_Service()
    checkAuth       =  (req,res,next) -> expressService.checkAuth(req, res,next, app.config)

    searchController_PoC = (method_Name) ->
        return (req, res) ->
            new Search_Controller_PoC(req, res, app.config)[method_Name]()


    app.get "/-poc-/search-two-column"       , checkAuth,  searchController_PoC('poc_Search_Two_Column')

module.exports = Search_Controller_PoC