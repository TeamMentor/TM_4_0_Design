fs              = require('fs')
path            = require('path')
request         = require('request')
Config          = require('../misc/Config')
Express_Service = require('../services/Express-Service')
Jade_Service    = require('../services/Jade-Service')
GitHub_Service  = require('../services/GitHub-Service')
Graph_Service   = require('../services/Graph-Service')
TeamMentor_Service = require('../services/TeamMentor-Service')

recentArticles_Cache = []
breadcrumbs_Cache    = []

class SearchController
    constructor: (req, res, config)->
        @req              = req
        @res              = res
        @config           = config || new Config()
        @jade_Page        = '/source/jade/user/search.jade'
        @jade_Service     = new Jade_Service(@config)
        @teamMentor_Service = new TeamMentor_Service
        @searchData       = null
        @defaultUser        = 'TMContent'
        @defaultRepo        = 'TM_Test_GraphData'
        @defaultFolder    = '/SearchData/'
        @defaultDataFile  = 'Data_Validation'        
    
    renderPage: ()->
        @jade_Service.renderJadeFile(@jade_Page, @searchData)

        
    showSearchFromGraph: ()=>        
        queryId = @req.params.queryId        
        filters = @req.params.filters

        breadcrumbs_Cache = breadcrumbs_Cache.splice(0,3)
        if (filters)
            breadcrumbs_Cache.unshift  {href:"/graph/#{queryId}/#{filters}", title: filters}
        else
            breadcrumbs_Cache.unshift  {href:"/graph/#{queryId}", title: queryId}
        
        
        graphService = new Graph_Service()
        graphService.graphDataFromGraphDB null, queryId, filters,  (searchData)=>
          searchData.filter_container = filters
          @searchData = searchData
          searchData.breadcrumbs = breadcrumbs_Cache
          @res.send(@renderPage())

    showMainAppView: =>
        breadcrumbs_Cache.unshift {href:"/user/main.html", title: "Search Home"}
        topArticles = 'http://localhost:1332/data/tm-data/articles-by-weight'
        #topArticles = 'https://tm-graph.herokuapp.com/data/tm-data/articles-by-weight'
        request topArticles, (err, response, data)=>
            console.log "data" + data
            jadePage  = 'source/jade/user/main.jade'  # relative to the /views folder
            viewModel = { recentArticles: @recentArticles() }

            #if false then ->
            #    data = JSON.parse(data).splice(0,4)
            #    topArticles = []
            #    for item in data
            #        topArticles.push { href: "/article/view/#{item.guid}/#{item.title}", title: "#{item.title}", weight:"#{item.weight}"}
            #
            #    searchTerms = []
            #    searchTerms.push { href: "/graph/Logging"                                   , title: "Logging"}
            #    searchTerms.push { href: "/graph/Separation%20of%20Data%20and%20Control"    , title: "Separation of Data and Control"}
            #    searchTerms.push { href: "/graph/(Web) Encoding"                            , title: "(Web) Encoding"}
            #    recentArticles = []
            #    for recentArticle in recentArticles_Cache
            #        recentArticles.push {href : 'https://tmdev01-uno.teammentor.net/'+recentArticle.guid , title:recentArticle.title}
            #        break if recentArticles.length >2
            #    viewModel = { recentArticles: recentArticles, topArticles : topArticles , searchTerms : searchTerms}
            #console.log "jadePage: " + jadePage
            @res.render(jadePage, viewModel)
            
    recentArticles: =>
        @.req.session ?= {}
        @.req.session.recent_Articles ?= []
        recentArticles = []
        for recentArticle in @.req.session.recent_Articles.take(2)
            recentArticles.push({href : @.teamMentor_Service.tm_35_Server + '/' + recentArticle.id , title:recentArticle.title})
        #        .push {href : 'https://tmdev01-uno.teammentor.net/'+recentArticle.guid , title:recentArticle.title}
        #        break if recentArticles.length >2
        recentArticles

    recentArticles_add: (id, title)=>
        @.req.session.recent_Articles ?= []
        @.req.session.recent_Articles.unshift { id: id , title:title}

    showArticle: =>
        id = @req.params.guid
        title = @req.params.title
        #recentArticles_Cache.unshift ({ guid: guid , title:title})
        @recentArticles_add id, title
        #@res.send(@.req.session)
        @res.redirect('https://tmdev01-uno.teammentor.net/'+id)



SearchController.registerRoutes = (app) ->

    checkAuth        =  (req,res,next) -> new Express_Service().checkAuth(req, res,next, app.config)

    searchController = (method_Name) ->                                  # pins method_Name value
        return (req, res) ->                                             # returns function for express
            new SearchController(req, res, app.config)[method_Name]()    # creates SearchController object with live
                                                                         # res,req and invokes method_Name

    app.get '/graph/:queryId'           , checkAuth , searchController('showSearchFromGraph')
    app.get '/graph/:queryId/:filters'  , checkAuth , searchController('showSearchFromGraph')
    app.get '/user/main.html'           , checkAuth , searchController('showMainAppView')
    app.get '/article/view/:guid/:title', checkAuth , searchController('showArticle')
                
module.exports = SearchController