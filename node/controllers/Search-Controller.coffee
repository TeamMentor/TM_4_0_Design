fs                 = require('fs')
path               = require('path')
request            = require('request')
Config             = require('../misc/Config')
Express_Service    = require('../services/Express-Service')
Jade_Service       = require('../services/Jade-Service')
GitHub_Service     = require('../services/GitHub-Service')
Graph_Service      = require('../services/Graph-Service')
TeamMentor_Service = require('../services/TeamMentor-Service')

recentArticles_Cache = []

recentSearches_Cache = ["Logging","Authorization","Administrative Controls"]

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

    
    renderPage: ()->
        @jade_Service.renderJadeFile(@jade_Page, @searchData)

    get_Navigation: (queryId, callback)=>

      @graphService.resolve_To_Ids queryId, (data)=>
        navigation = []
        path = null
        for key in data.keys()
          item = data[key]
          path = if path then "#{path},#{key}" else "#{key}"
          navigation.push {href:"/graph/#{path}", title: item.title , id: item.id }

        callback navigation

    showSearchFromGraph: ()=>        
        queryId = @req.params.queryId
        filters = @req.params.filters

        @get_Navigation queryId, (navigation)=>
          target = navigation.last() || {}
          @graphService.graphDataFromGraphDB null, target.id, filters,  (searchData)=>
            searchData.filter_container = filters
            @searchData = searchData
            @searchData.breadcrumbs = navigation #@get_Navigation(queryId, searchData.title)
            @searchData.href = target.href
            @res.send(@renderPage())

    showMainAppView: =>

        jadePage  = 'source/jade/user/main.jade'  # relative to the /views folder
        @topArticles (topArticles)=>
            viewModel = { recentArticles: @recentArticles() , topArticles : topArticles, searchTerms : @topSearches() }
            @res.render(jadePage, viewModel)

    topArticles: (callback)=>
        topArticles_Url = "http://localhost:1337/article/viewed.json"
        topArticles_Url.GET_Json (data)=>
            if (is_Null(data))
                callback []
                return
            results = {}
            for item in data
                results[item.id] ?= { href: "/article/view/#{item.id}/#{item.title}", title: item.title, weight: 0}
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
            searchTerms.unshift { href: "/graph/#{search}", title: search}

        return searchTerms.take(3)

    recentArticles: =>
        @.req.session ?= {}
        @.req.session.recent_Articles ?= []
        recentArticles = []
        for recentArticle in @.req.session.recent_Articles.take(3)
            recentArticles.push({href : @config.tm_35_Server + recentArticle.id , title:recentArticle.title})
        recentArticles

    recentArticles_add: (id, title)=>
        @.req.session.recent_Articles ?= []
        @.req.session.recent_Articles.unshift { id: id , title:title}

    showArticle: =>
        id = @req.params.guid
        title = @req.params.title
        @recentArticles_add id, title
        @res.redirect(@config.tm_35_Server+id)

    search: =>
        target = @.req.query.text
        recentSearches_Cache.push(target)
        @res.redirect('/graph/' + target)

SearchController.registerRoutes = (app, expressService) ->

    expressService ?= new Express_Service()
    checkAuth        =  (req,res,next) -> expressService.checkAuth(req, res,next, app.config)

    searchController = (method_Name) ->                                  # pins method_Name value
        return (req, res) ->                                             # returns function for express
            new SearchController(req, res, app.config)[method_Name]()    # creates SearchController object with live
                                                                         # res,req and invokes method_Name

    viewedArticles_json = (req,res)=>
        expressService.expressSession.db.find {}, (err,sessionData)->
            recent_Articles = []
            if sessionData
                for session in sessionData
                    if session.data.recent_Articles
                        for recent_article in session.data.recent_Articles
                            recent_Articles.add(recent_article)
            res.send(recent_Articles)

    app.get '/'                         , checkAuth , searchController('showMainAppView')
    app.get '/graph/:queryId'           , checkAuth , searchController('showSearchFromGraph')
    app.get '/graph/:queryId/:filters'  , checkAuth , searchController('showSearchFromGraph')
    app.get '/user/main.html'           , checkAuth , searchController('showMainAppView')
    app.get '/article/view/:guid/:title', checkAuth , searchController('showArticle')
    app.get '/article/viewed.json'      ,             viewedArticles_json
    app.get '/search'                   , checkAuth,  searchController('search')
module.exports = SearchController