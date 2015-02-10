fs                 = require('fs')
path               = require('path')
request            = require('request')
Config             = require('../misc/Config')
Express_Service    = require('../services/Express-Service')
Jade_Service       = require('../services/Jade-Service')
Graph_Service      = require('../services/Graph-Service')
TeamMentor_Service = require('../services/TeamMentor-Service')


recentSearches_Cache = ["Logging","Struts","Administrative Controls"]


class SearchController
    constructor: (req, res, config)->
        @req                = req
        @res                = res
        @config             = config || new Config()
        @jade_Page          = '/source/jade/user/search.jade'
        @jade_Service       = new Jade_Service(@config)
        @teamMentor_Service = new TeamMentor_Service
        @graphService       = new Graph_Service()
        @searchData         = null
        @defaultUser        = 'TMContent'
        @defaultRepo        = 'TM_Test_GraphData'
        @defaultFolder      = '/SearchData/'
        @defaultDataFile    = 'Data_Validation'
        @urlPrefix          = '-'

    
    renderPage: ()->
        @jade_Service.renderJadeFile(@jade_Page, @searchData)

    get_Navigation: (queryId, callback)=>

      @graphService.resolve_To_Ids queryId, (data)=>
        navigation = []
        path = null
        for key in data.keys()
          item = data[key]
          path = if path then "#{path},#{key}" else "#{key}"
          if item and path
            navigation.push {href:"/#{@urlPrefix}/#{path}", title: item.title , id: item.id }

        callback navigation

    showSearchFromGraph: ()=>        
        queryId = @req.params.queryId
        filters = @req.params.filters

        @get_Navigation queryId, (navigation)=>
          target = navigation.last() || {}
          @graphService.graphDataFromGraphDB target.id, filters,  (searchData)=>
            searchData.filter_container = filters
            @searchData = searchData
            @searchData.breadcrumbs = navigation
            @searchData.href = target.href
            if filters
              @graphService.resolve_To_Ids filters, (results)=>
                @searchData.activeFilter = results.values()?.first()
                @res.send(@renderPage())
            else
              @res.send(@renderPage())

    search: =>
      target = @.req.query.text
      filter = @.req.query.filter?.substring(1)
      jade_Page = '/source/jade/user/search-two-columns.jade'

      @graphService.query_From_Text_Search target,  (query_Id)=>
        query_Id = query_Id?.remove '"'
        @graphService.graphDataFromGraphDB query_Id, filter,  (searchData)=>

          searchData.text         =  target
          searchData.href         = "/search?text=#{target}&filter="
          log searchData
          if searchData?.id
            recentSearches_Cache.push target
          else
            searchData.no_Results = true
            @res.send @jade_Service.renderJadeFile(jade_Page, searchData)
            return
          if filter
            @graphService.resolve_To_Ids filter, (results)=>
              searchData.activeFilter = results.values()?.first()
              #searchData.activeFilter = { id: filter, title: filter }
              @res.send @jade_Service.renderJadeFile(jade_Page, searchData)
          else
            @res.send @jade_Service.renderJadeFile(jade_Page, searchData)

    showRootQueries: ()=>
      @graphService.root_Queries (root_Queries)=>
        @searchData = root_Queries
        @searchData.breadcrumbs = [{href:"/#{@urlPrefix}/", title: '/' , id: '/' }]
        @searchData.href = "/#{@urlPrefix}/"
        @res.send(@renderPage())


    showMainAppView: =>

        jadePage  = 'source/jade/user/main.jade'  # relative to the /views folder
        @topArticles (topArticles)=>
            #recentArticles =  @recentArticles()
            viewModel = {  recentArticles: {}, topArticles : topArticles, searchTerms : @topSearches() }
            @res.render(jadePage, viewModel)

    topArticles: (callback)=>
        topArticles_Url = "http://localhost:1337/article/viewed.json"
        topArticles_Url.GET_Json (data)=>
            if (is_Null(data))
                callback []
                return
            results = {}
            for item in data
                results[item.id] ?= { href: "/article/#{item.id}", title: item.title, weight: 0}
                results[item.id].weight++
            results = (results[key] for key in results.keys())

            results = results.sort (a,b)-> a.weight > b.weight
            topResults = []
            topResults.add(results.pop()).add(results.pop())
                      .add(results.pop()).add(results.pop())
                      .add(results.pop())
            callback topResults

    topSearches: =>
        searchTerms = []
        for search in recentSearches_Cache
            searchTerms.unshift { href: "/search?text=#{search}", title: search}

        return searchTerms.take(3)



SearchController.registerRoutes = (app, expressService) ->

    expressService ?= new Express_Service()
    checkAuth       =  (req,res,next) -> expressService.checkAuth(req, res,next, app.config)
    urlPrefix       = new SearchController().urlPrefix                   # urlPrefix should be moved to a global static var

    searchController = (method_Name) ->                                  # pins method_Name value
        return (req, res) ->                                             # returns function for express
            new SearchController(req, res, app.config)[method_Name]()    # creates SearchController object with live
                                                                         # res,req and invokes method_Name


    app.get "/"                              , checkAuth , searchController('showMainAppView')
    app.get "/#{urlPrefix}"                  , checkAuth , searchController('showRootQueries')
    app.get "/#{urlPrefix}/:queryId"         , checkAuth , searchController('showSearchFromGraph')
    app.get "/#{urlPrefix}/:queryId/:filters", checkAuth , searchController('showSearchFromGraph')
    app.get "/user/main.html"                , checkAuth , searchController('showMainAppView')
    app.get "/search"                        , checkAuth,  searchController('search')
    #app.get "/search/:text"                  , checkAuth,  searchController('search')

module.exports = SearchController