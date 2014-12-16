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
        @jade_Page        = '/source/jade/user/search.jade'
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
        
    
#   searchDataFile: ->
#       content_File = '/source/content/search_data/main.json'
#       return path.join(process.cwd(), content_File)
#       
#   loadSearchData: ->
#       jsonFile = @searchDataFile()
#       if (fs.existsSync(jsonFile))
#           @searchData = JSON.parse(fs.readFileSync(jsonFile, 'utf8'))
#       return this

#   getSearchDataFromRepo: (file, callback) =>
#       new GitHub_Service().file(@defaultUser, @defaultRepo, @defaultFolder + file + '.json', callback)

#   showSearch: () ->
#       if (@req.params.file)
#           fileToUse = @req.params.file
#       else
#           fileToUse = @defaultDataFile
#       
#       @getSearchDataFromRepo fileToUse, (data) =>
#           try
#               @searchData = JSON.parse(data)
#           catch error
#               @searchData = { title: 'JSON Parsing error' , resultsTitle : error}
#           @res.send(@renderPage())
#   
   #showSearchFromGraph: ()=>
   #    graphService = new Graph_Service()
   #    graphService.loadTestData =>
   #        graphService.createSearchData 'Data from Graph',( searchData) =>
   #            @searchData = searchData
   #            graphService.closeDb =>
   #                @res.send(@renderPage())
    search : ()=>
        server = 'http://localhost:1332';
        url    = '/data/tm-uno/queries';
        text = @req.query.text
        
        request server + url, (error, response,data) =>
            graph = JSON.parse(data);
            nodes = graph.nodes;
            node_Labels = [];
            nodes.forEach (node)=> node_Labels.push(node.label)
            allQueries =  node_Labels.sort();
            foundQuery = ""
            if (allQueries.contains(text))
                foundQuery = text
            else
                text = text.lower()
                foundQuery = query for query in allQueries when query.lower().indexOf(text) > -1
            if (foundQuery == "")
                @res.redirect('/user/main.html')
            else            
                @res.redirect("/graph/#{foundQuery}")
            
        
    showSearchFromGraph: ()=>        
        queryId = @req.params.queryId        
        filters = @req.params.filters
        console.log queryId
        breadcrumbs_Cache = breadcrumbs_Cache.splice(0,3)
        if (filters)
            breadcrumbs_Cache.unshift  {href:"/graph/#{queryId}/#{filters}", title: filters}
        else
            breadcrumbs_Cache.unshift  {href:"/graph/#{queryId}", title: queryId}
        
        
        graphService = new Graph_Service()
        graphService.graphDataFromGraphDB null, queryId, filters,  (searchData)=>
                searchData.filter_container = filters
        #graphService.graphDataFromQAServer dataId, (graphData)=>
        #    graphService.createSearchDataFromGraphData graphData,@req.query.left, @req.query.right, (searchData)=>
                @searchData = searchData
                searchData.breadcrumbs = breadcrumbs_Cache
                @res.send(@renderPage())
    
    showSearchData: ->
        @res.set('Content-Type', 'application/json')
            .send(JSON.stringify(@loadSearchData().searchData,null, ' '))
            
    showMainAppView: =>
        breadcrumbs_Cache.unshift {href:"/user/main.html", title: "Search Home"}
        topArticles = 'http://localhost:1332/data/tm-data/articles-by-weight'
        #topArticles = 'https://tm-graph.herokuapp.com/data/tm-data/articles-by-weight'
        request topArticles, (err, response, data)=>
            console.log "data" + data
            jadePage  = '../source/jade/user/main.jade'  # relative to the /views folder
            viewModel = {}
            if false then ->
                data = JSON.parse(data).splice(0,4)
                topArticles = []
                for item in data
                    topArticles.push { href: "/article/view/#{item.guid}/#{item.title}", title: "#{item.title}", weight:"#{item.weight}"}

                searchTerms = []
                searchTerms.push { href: "/graph/Logging"                                   , title: "Logging"}
                searchTerms.push { href: "/graph/Separation%20of%20Data%20and%20Control"    , title: "Separation of Data and Control"}
                searchTerms.push { href: "/graph/(Web) Encoding"                            , title: "(Web) Encoding"}
                recentArticles = []
                for recentArticle in recentArticles_Cache
                    recentArticles.push {href : 'https://uno.teammentor.net/'+recentArticle.guid , title:recentArticle.title}
                    break if recentArticles.length >2
                viewModel = { recentArticles: recentArticles, topArticles : topArticles , searchTerms : searchTerms}
            console.log "jadePage: " + jadePage
            @res.render(jadePage, viewModel)
            
    showArticle: =>
        guid = @req.params.guid
        title = @req.params.title
        recentArticles_Cache.unshift ({ guid: guid , title:title})
        @res.redirect('https://uno.teammentor.net/'+guid)

SearchController.registerRoutes = (app) ->
    #app.get('/search'                 , (req, res) -> new SearchController(req, res, app.config).showSearch())
    #app.get('/search.json'            , (req, res) -> new SearchController(req, res, app.config).showSearchData())
    #app.get('/search/:file'           , (req, res) -> new SearchController(req, res, app.config).showSearch())
    app.get('/search'                  , (req, res) -> new SearchController(req, res, app.config).search())
    app.get('/graph/:queryId'         , (req, res) -> new SearchController(req, res, app.config).showSearchFromGraph())    
    app.get('/graph/:queryId/:filters', (req, res) -> new SearchController(req, res, app.config).showSearchFromGraph())    
    
    app.get '/user/main.html'  , (req,res) -> new SearchController(req, res, app.config).showMainAppView()
    app.get '/article/view/:guid/:title', (req,res) -> new SearchController(req, res, app.config).showArticle()
    #app.get('/search' , (req, res) -> res.send('a'))
                
module.exports = SearchController