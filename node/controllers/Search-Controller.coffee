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
        @defaultGist  = 'DinisCruz/ad328585205f67569e0d/raw/Search_Data_Validation.json'
    
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

    getSearchDataFromGist: (gistId, callback) ->
        gistUrl = 'https://gist.githubusercontent.com/' + gistId
        require('request').get gistUrl, (error, response, body) =>
            callback(body)

    showSearch: () ->        
        if (@req.params.name && @req.params.id)
            gistToUse = "#{@req.params.name}/#{@req.params.id}/raw/#{@req.params.file}";
        else
            gistToUse = @defaultGist
        
        @getSearchDataFromGist gistToUse, (data) =>
            @searchData = JSON.parse(data)
            @res.send(@renderPage())
    
    showSearchData: ->
        @res.set('Content-Type', 'application/json')
            .send(JSON.stringify(@loadSearchData().searchData,null, ' '))

SearchController.registerRoutes = (app) ->
    app.get('/search'                    , (req, res) -> new SearchController(req, res, app.config).showSearch())
    app.get('/search.json'               , (req, res) -> new SearchController(req, res, app.config).showSearchData())
    app.get('/search/gist/:name/:id/:file'      , (req, res) -> new SearchController(req, res, app.config).showSearch())
        
    #app.get('/search' , (req, res) -> res.send('a'))
                
module.exports = SearchController