fs              = require('fs')
path            = require('path')
Config          = require('../Config')
Jade_Service    = require('../services/Jade-Service')
GitHub_Service  = require('../services/GitHub-Service')
Graph_Service  = require('../services/Graph-Service')

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
    
    showSearchFromGraph: ()=>
        graphService = new Graph_Service()
        graphService.loadTestData =>
            graphService.createSearchData 'Data from Graph',( searchData) =>
                @searchData = searchData
                graphService.closeDb =>
                    @res.send(@renderPage())
    
    showSearchData: ->
        @res.set('Content-Type', 'application/json')
            .send(JSON.stringify(@loadSearchData().searchData,null, ' '))

SearchController.registerRoutes = (app) ->
    app.get('/search'                 , (req, res) -> new SearchController(req, res, app.config).showSearch())
    app.get('/search.json'            , (req, res) -> new SearchController(req, res, app.config).showSearchData())
    app.get('/search/:file'           , (req, res) -> new SearchController(req, res, app.config).showSearch())
    app.get('/graph'                  , (req, res) -> new SearchController(req, res, app.config).showSearchFromGraph())
        
    #app.get('/search' , (req, res) -> res.send('a'))
                
module.exports = SearchController