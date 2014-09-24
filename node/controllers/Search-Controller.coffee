fs           = require('fs')
path         = require('path')
Config       = require('../Config')
Jade_Service = require('../services/Jade-Service')

class SearchController
    constructor: (req, res, config)->
        @req          = req
        @res          = res
        @config       = config || new Config()
        @jade_Page    = '/source/html/search/main.jade'
        @jade_Service = new Jade_Service(@config)
        @searchData   = null
    
    renderPage: (params)->
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

    showSearch: ->
        @res.send(@renderPage(null))
    
    showSearchData: ->
        @res.send(JSON.stringify(@loadSearchData().searchData,null, ' '))

SearchController.registerRoutes = (app) ->
    app.get('/search'      , (req, res) -> new SearchController(req, res, app.config).showSearch())
    app.get('/search.json' , (req, res) -> new SearchController(req, res, app.config).showSearchData())
    #app.get('/search' , (req, res) -> res.send('a'))
                
module.exports = SearchController