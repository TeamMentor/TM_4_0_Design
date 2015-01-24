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

    object_Data = "#{@server}/graph-db/object/#{queryId}"
    object_Data.GET_Json (json)=>

      log json
      if json and json.not_Empty() and (json.first().predicate is 'title')
        queryId = json.first().subject
      log json and (json.predicate is 'title')
      log queryId

      #server = 'https://tm-graph.herokuapp.com'
      dataId = dataId || 'tm-uno'
      #graphDataUrl = "#{@server}/data/#{dataId}/query/filter/tm-search?show=#{queryId}"
      #graphDataUrl = "#{@server}/view/tm-search/#{queryId}"
      #graphDataUrl = "#{@server}/graph-db/filter/#{queryId}"
      graphDataUrl = "#{@server}/data/query_tree/#{queryId}"

      #log graphDataUrl
      #if (filters)
      #    graphDataUrl += "&filters=#{filters}"
      #console.log("****:   " + graphDataUrl)
      require('request').get graphDataUrl, (err,response,body)->
          if (err)
              callback {}
          else
              callback JSON.parse(body)


module.exports = GraphService