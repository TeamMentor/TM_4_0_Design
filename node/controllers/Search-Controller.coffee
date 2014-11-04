fs              = require('fs')
path            = require('path')
Config          = require('../Config')
request         = require('request')
Jade_Service    = require('../services/Jade-Service')
GitHub_Service  = require('../services/GitHub-Service')
Graph_Service  = require('../services/Graph-Service')

recentArticles_Cache = []
breadcrumbs_Cache    = []

class SearchController
    constructor: (req, res, config)->
        @req              = req
        @res              = res
        @config           = config || new Config()
        @jade_Page        = '/source/html/search/main.jade'
        @jade_Service     = new Jade_Service(@config)
        @searchData       = null
        @defaultUser      = "TMContent"
        @defaultRepo      = "TM_Test_GraphData"
        @defaultFolder    = '/SearchData/'
        @defaultDataFile  = 'Data_Validation'        
    
    renderPage: ()->
        if not @searchData
            @loadSearchData()
        @jade_Service.renderJadeFile(@jade_Page, @searchData)
        
    
    searchDataFile: ->
        content_File = '/source/content/search_data/main.json'
        return path.join(process.cwd(), content_File)
        
    loadSearchData: ->
        jsonFile = @searchDataFile()
        if (fs.existsSync(jsonFile))
            @searchData = JSON.parse(fs.readFileSync(jsonFile, 'utf8'))
        return this

    getSearchDataFromRepo: (file, callback) =>
        new GitHub_Service().file(@defaultUser, @defaultRepo, @defaultFolder + file + '.json', callback)

    showSearch: () ->
        if (@req.params.file)
            fileToUse = @req.params.file
        else
            fileToUse = @defaultDataFile
        
        @getSearchDataFromRepo fileToUse, (data) =>
            try
                @searchData = JSON.parse(data)
            catch error
                @searchData = { title: 'JSON Parsing error' , resultsTitle : error}
            @res.send(@renderPage())
    
   #showSearchFromGraph: ()=>
   #    graphService = new Graph_Service()
   #    graphService.loadTestData =>
   #        graphService.createSearchData 'Data from Graph',( searchData) =>
   #            @searchData = searchData
   #            graphService.closeDb =>
   #                @res.send(@renderPage())
   
    showSearchFromGraph: ()=>
        dataId = @req.params.dataId
        breadcrumbs_Cache = breadcrumbs_Cache.splice(0,3)
        breadcrumbs_Cache.unshift  {href:"/graph/#{dataId}", title: dataId}
        
        
        graphService = new Graph_Service()
        graphService.graphDataFromQAServer dataId, (graphData)=>
            graphService.createSearchDataFromGraphData graphData,@req.query.left, @req.query.right, (searchData)=>
                @searchData = searchData
                searchData.breadcrumbs = breadcrumbs_Cache
                @res.send(@renderPage())
    
    showSearchData: ->
        @res.set('Content-Type', 'application/json')
            .send(JSON.stringify(@loadSearchData().searchData,null, ' '))
            
    showMainAppView: =>
        breadcrumbs_Cache.unshift {href:"/home/main-app-view.html", title: "Search Home"}
        topArticles = 'http://localhost:1332/data/tm-data/articles-by-weight'
        #topArticles = 'https://tm-graph.herokuapp.com/data/tm-data/articles-by-weight'
        request topArticles, (err, respojnse, data)=>
            data = JSON.parse(data).splice(0,4)
            topArticles = []
            for item in data
                topArticles.push { href: "/article/view/#{item.guid}/#{item.title}", title: "#{item.title}", weight:"#{item.weight}"}
            
            searchTerms = []
            searchTerms.push { href: "/graph/input-validation" , title: "Input validation"}
            searchTerms.push { href: "/graph/sql-injection"    , title: "Sql Injection"}
            searchTerms.push { href: "/graph/tm-data"          , title: "TM Data"}
            recentArticles = []
            for recentArticle in recentArticles_Cache
                recentArticles.push {href : 'https://tmdev01-sme.teammentor.net/'+recentArticle.guid , title:recentArticle.title}
                break if recentArticles.length >2
            viewModel = { recentArticles: recentArticles, topArticles : topArticles , searchTerms : searchTerms}
            jadePage  = '../source/html/home/main-app-view.jade'
            @res.render(jadePage, viewModel)
            
    showArticle: =>
        guid = @req.params.guid
        title = @req.params.title
        recentArticles_Cache.unshift ({ guid: guid , title:title})
        @res.redirect('https://tmdev01-sme.teammentor.net/'+guid)

SearchController.registerRoutes = (app) ->
    app.get('/search'                 , (req, res) -> new SearchController(req, res, app.config).showSearch())
    app.get('/search.json'            , (req, res) -> new SearchController(req, res, app.config).showSearchData())
    app.get('/search/:file'           , (req, res) -> new SearchController(req, res, app.config).showSearch())
    app.get('/graph/:dataId'          , (req, res) -> new SearchController(req, res, app.config).showSearchFromGraph())
    app.get('/graph/:dataId'          , (req, res) -> new SearchController(req, res, app.config).showSearchFromGraph())
    
    app.get '/home/main-app-view.html'  , (req,res) -> new SearchController(req, res, app.config).showMainAppView()
    app.get '/article/view/:guid/:title', (req,res) -> new SearchController(req, res, app.config).showArticle()
    #app.get('/search' , (req, res) -> res.send('a'))
                
module.exports = SearchController