fs                 = null
path               = null
request            = null
Config             = null
Express_Service    = null
Jade_Service       = null
Graph_Service      = null


recentSearches_Cache = ["Logging","Struts","Administrative Controls"]
url_Prefix           = 'show'

class SearchController
    constructor: (req, res, config,express_Service)->

        fs                 = require('fs')
        path               = require('path')
        request            = require('request')
        Config             = require('../misc/Config')
        Express_Service    = require('../services/Express-Service')
        Jade_Service       = require('../services/Jade-Service')
        Graph_Service      = require('../services/Graph-Service')
        @.req                = req
        @.res                = res
        @.config             = config || new Config()
        @.express_Service    = express_Service
        @.jade_Service       = new Jade_Service(@config)
        @.graph_Service      = new Graph_Service()
        @.jade_Page          = '/source/jade/user/search.jade'
        @.jade_Error_Page    = '/source/jade/guest/404.jade'
        @.defaultUser        = 'TMContent'
        @.defaultRepo        = 'TM_Test_GraphData'
        @.defaultFolder      = '/SearchData/'
        @.defaultDataFile    = 'Data_Validation'
        @.urlPrefix          = url_Prefix
        @.searchData         = null


    
    renderPage: ()->
        @jade_Service.renderJadeFile(@jade_Page, @searchData)

    get_Navigation: (queryId, callback)=>

      @.graph_Service.resolve_To_Ids queryId, (data)=>
        navigation = []
        path = null
        for key in data.keys()
          item = data[key]
          path = if path then "#{path},#{key}" else "#{key}"
          if item and path
            navigation.push {href:"/#{@urlPrefix}/#{path}", title: item.title , id: item.id }

        callback navigation

    showSearchFromGraph: ()=>        
        queryId = @.req.params.queryId
        filters = @.fix_Filters @req.params.filters

        logger?.info {user: @.req.session?.username, action:'show', queryId: queryId, filters:filters}

        if (not queryId?)
          logger?.info {Error:'GraphDB might not be available, please verify.'}

        @get_Navigation queryId, (navigation)=>
          target = navigation.last() || {}
          @graph_Service.graphDataFromGraphDB target.id, filters,  (searchData)=>
            @searchData = searchData
            if not searchData
              @res.send(@renderPage())
              return
            searchData.filter_container = filters
            @searchData.breadcrumbs = navigation
            @searchData.href = target.href
            if filters
              @graph_Service.resolve_To_Ids filters, (results)=>
                @searchData.activeFilter         = results.values()
                @searchData.activeFilter.ids     = (value.id for value in results.values())
                @searchData.activeFilter.titles  = (value.title for value in results.values())
                @searchData.activeFilter.filters = filters
                if (@searchData.results?)
                  @res.send(@renderPage())
                else
                  logger?.info {Error:'There are no results that match the search.',queryId: queryId, filters:filters}
                  @res.send @jade_Service.renderJadeFile(@.jade_Error_Page,{loggedIn:@.req.session?.username isnt undefined})
            else
              if (@searchData.results?)
                @res.send(@renderPage())
              else
                logger?.info {Error:'There are no results that match the search.',queryId: queryId, filters:filters}
                @res.send @jade_Service.renderJadeFile(@.jade_Error_Page,{loggedIn:@.req.session?.username isnt undefined})

    search_Via_Url: =>
      @.req.query.text = @.req.params.text
      @.search()

    fix_Filters: (filters)=>
      if filters
        if filters.substring(0,1) is ','
          filters = filters.substring(1)
        if filters.substring(filters.length-1,filters.length) is ','
          filters = filters.substring(0, filters.length-1)
        filters = filters.replace(',,',',')


    search: =>
      target  = @.req.query?.text
      filters = @.fix_Filters @.req.query?.filters?.substring(1)


      logger?.info {user: @.req.session?.username, action:'search', target: target, filters:filters}

      jade_Page = '/source/jade/user/search-two-columns.jade'

      @graph_Service.query_From_Text_Search target,  (query_Id)=>
        query_Id = query_Id?.remove '"'
        @graph_Service.graphDataFromGraphDB query_Id, filters,  (searchData)=>
          if not searchData
            @res.send @jade_Service.renderJadeFile(jade_Page, {})
            return

          searchData.text         =  target
          searchData.href         = "/search?text=#{target?.url_Encode()}&filters="

          @.req.session.user_Searches ?= []

          if searchData?.id
            user_Search = { id: searchData.id, title: searchData.title, results: searchData.results.size(), username: @.req.session.username }
            @.req.session.user_Searches.push user_Search
          else
            user_Search = { title: target, results: 0, username: @.req.session?.username }
            @.req.session.user_Searches.push user_Search
            searchData.no_Results = true
            @res.send @jade_Service.renderJadeFile(jade_Page, searchData)
            return

          if filters
            @graph_Service.resolve_To_Ids filters, (results)=>
              #searchData.activeFilter = results.values()?.first()
              searchData.activeFilter         = results.values()
              searchData.activeFilter.ids     = (value.id for value in results.values())
              searchData.activeFilter.titles  = (value.title for value in results.values())
              searchData.activeFilter.filters = filters
              @res.send @jade_Service.renderJadeFile(jade_Page, searchData)
          else
            @res.send @jade_Service.renderJadeFile(jade_Page, searchData)


    show_Root_Query: ()=>
      @.graph_Service.library_Query (data)=>
        @.req.params.queryId = data.queryId
        @.showSearchFromGraph()

    showMainAppView: =>
        jadePage  = 'source/jade/user/main.jade'  # relative to the /views folder

        @.express_Service.session_Service.user_Data @.req.session, (user_Data)=>
          viewModel = user_Data
          @res.render(jadePage, viewModel)

SearchController.register_Routes = (app, expressService) ->

    expressService ?= new Express_Service()
    checkAuth       =  (req,res,next) -> expressService.checkAuth(req, res,next, app.config)
    urlPrefix       = url_Prefix            # urlPrefix should be moved to a global static class

    searchController = (method_Name) ->                                  # pins method_Name value
        return (req, res) ->                                             # returns function for express
            new SearchController(req, res, app.config,expressService)[method_Name]()    # creates SearchController object with live
                                                                         # res,req and invokes method_Name

    app.get "/"                              , checkAuth , searchController('showMainAppView')
    app.get "/#{urlPrefix}"                  , checkAuth , searchController('show_Root_Query')
    app.get "/#{urlPrefix}/:queryId"         , checkAuth , searchController('showSearchFromGraph')
    app.get "/#{urlPrefix}/:queryId/:filters", checkAuth , searchController('showSearchFromGraph')
    app.get "/user/main.html"                , checkAuth , searchController('showMainAppView')
    app.get "/search"                        , checkAuth,  searchController('search')
    app.get "/search/:text"                  , checkAuth,  searchController('search_Via_Url')

module.exports = SearchController