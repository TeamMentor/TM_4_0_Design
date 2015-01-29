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

  render_Page: (jade_Page,data)=>
    html = @jade_Service.renderJadeFile(jade_Page, data)
    @res.send html

  poc_Pages: =>
    target    = @.req.query.text
    jade_Page = '/source/jade/-poc-/poc-pages.jade'
    data =
      pages: [{ name: 'PoC pages'           , link: ''}
              { name: 'Search - Two Columns', link: 'search-two-column'}]
    @render_Page jade_Page, data

  poc_Search_Two_Column: =>
    target = @.req.query.text
    jade_Page = '/source/jade/-poc-/search/two-columns.jade'

    @graphService.query_From_Text_Search target,  (query_Id)=>
      @graphService.graphDataFromGraphDB query_Id, null,  (searchData)=>
        searchData.text = target
        @render_Page jade_Page, searchData




Search_Controller_PoC.registerRoutes = (app, expressService) ->

    expressService ?= new Express_Service()
    checkAuth       =  (req,res,next) -> expressService.checkAuth(req, res,next, app.config)

    searchController_PoC = (method_Name) ->
        return (req, res) ->
            new Search_Controller_PoC(req, res, app.config)[method_Name]()


    app.get "/-poc-/search-two-column"       , checkAuth,  searchController_PoC('poc_Search_Two_Column')
    app.get "/-poc-"                         , checkAuth,  searchController_PoC('poc_Pages')

module.exports = Search_Controller_PoC