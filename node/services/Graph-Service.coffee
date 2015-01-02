require('fluentnode')
fs         = require('fs')

#levelup    = require("levelup")
#levelup    = require("level"        )
#levelgraph      = require('levelgraph'   )
GitHub_Service  = require('./GitHub-Service')

class GraphService

  constructor: ->
    @dataFile   = './src/article-data.json'
    @data       = null
    @server     = 'http://localhost:1332'

  dataFromGitHub: (callback)->
    user   = "TMContent"
    repo   = "TM_Test_GraphData"
    path   = 'GraphData/article_Data.json'
    new GitHub_Service().file user, repo, path, (data)-> callback(JSON.parse(data))

  graphDataFromGraphDB: (dataId, queryId, filters, callback)->

    #server = 'https://tm-graph.herokuapp.com'
    dataId = dataId || 'tm-uno'
    graphDataUrl = "#{@server}/data/#{dataId}/query/filter/tm-search?show=#{queryId}"
    if (filters)
        graphDataUrl += "&filters=#{filters}"
    #console.log("****:   " + graphDataUrl)
    require('request').get graphDataUrl, (err,response,body)->
        if (err)
            callback {}
        else
            callback JSON.parse(body)


module.exports = GraphService