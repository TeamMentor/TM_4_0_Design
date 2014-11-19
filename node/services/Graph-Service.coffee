require('fluentnode')
fs         = require('fs')

#levelup    = require("levelup")
levelup    = require("level"        )
levelgraph      = require('levelgraph'   )
GitHub_Service  = require('./GitHub-Service')

class GraphService
    constructor: ->
                    #console.log('in ArticlesGraph ctor')
                    @dbPath     = './.tmCache/db'
                    @level      = null
                    @db         = null
                    @dataFile   = './src/article-data.json'
                    @data       = null                    
    
    #Setup methods
    
    closeDb: (callback)->
                if(@level == null)
                    callback()
                else
                    @level.close =>
                        @db.close =>
                            @db    = null
                            @level = null
                            callback()
                
    openDb : ->
                @level      = levelup   (@dbPath)
                @db         = levelgraph(@level)
                
    deleteDb: ->
        console.log 'Deleting the articleDB'
        require('child_process').spawn('rm', ['-Rv',@dbPath])
            
#    dataFilePath: -> process.cwd().path.join(@dataFile)
#    dataFromFile: ()-> JSON.parse fs.readFileSync(@dataFilePath(), "utf8")
    
    dataFromGitHub: (callback)->
        user   = "TMContent"
        repo   = "TM_Test_GraphData"
        path   = 'GraphData/article_Data.json'
        new GitHub_Service().file user, repo, path, (data)-> callback(JSON.parse(data))
    
    # Load from disk
    loadTestData: (callback) =>
        if (@db==null)
            @openDb()
        @dataFromGitHub (data)=>
            @data = data
            @db.put @data, callback
    
    # Search methods
    
    allData: (callback)->
        @db.search [{
                        subject  : @db.v("subject"),
                        predicate: @db.v("predicate"),
                        object   : @db.v("object"),
                    }], callback
     
    query: (key, value, callback)->
        switch key
            when "subject"      then @db.get { subject: value}, callback
            when "predicate"    then @db.get { predicate: value}, callback
            when "object"       then @db.get { object: value}, callback
            else callback(null,[])

    createSearchData: (folderName,callback)->
                
        searchData              = {}
        
        setDefaultValues = ->
            searchData.title        = folderName
            searchData.containers   = []
            searchData.resultsTitle = "n/n results showing"
            searchData.results      = []
            searchData.filters      = []
        
        metadata = {}
        
        mapMetadata = ()=>
            for item of metadata when typeof(metadata[item]) != 'function'
                filter = {}
                filter.title   = item
                filter.results = []
                for mapping of metadata[item]
                    if typeof(metadata[item][mapping]) != 'function'
                        result = { title : mapping , size: metadata[item][mapping]}
                        filter.results.push(result)
                searchData.filters.push(filter)
            callback(searchData)
            
        mapArticles = (articles) =>
            if (articles.empty())
                mapMetadata()
            else
                article = articles.pop()
                @query 'subject', article, (err,data) ->
                    result = { title: null, link: null , id: null, summary: null, score : null }
                    for item in data
                        switch item.predicate
                            when 'Guid'     then result.id = item.object
                            when 'Title'    then result.title = item.object
                            when 'Summary'  then result.summary = item.object
                            when 'is an'    then #do Nothing
                            when 'View'     then #do Nothing
                            else
                                if not metadata[item.predicate] then metadata[item.predicate] = {}
                                if metadata[item.predicate][item.object]
                                    metadata[item.predicate][item.object]++
                                else
                                    metadata[item.predicate][item.object] = 1
                    result.link = 'https://uno.teammentor.net/'+result.id
                    result.score = 0
                    searchData.results.push(result)
                    mapArticles(articles)
        
        mapViews = (viewsToMap,articles) =>
            if (viewsToMap.empty())
                mapArticles(articles)
            else
                viewToMap = viewsToMap.pop()
                @query 'subject', viewToMap.id, (err,data) ->
                    container = { title: null, id: null, size : viewToMap.size }
                    for item in data
                        switch item.predicate
                            when 'Guid'  then container.id = item.object
                            when 'Title' then container.title = item.object
                    searchData.containers.push(container)
                    mapViews(viewsToMap,articles)
            
        mapResults = (err,data) =>
            viewsCount = {}
            articles   = []
            for item in data
                articles.push(item.article)
                if viewsCount[item.view] then viewsCount[item.view]++ else viewsCount[item.view] = 1
                
            searchData.resultsTitle = "#{articles.length}/#{data.length} results showing"
            
            viewsToMap = ({ id: key, size: viewsCount[key]} for key of viewsCount when typeof(viewsCount[key]) != 'function')
            
            mapViews(viewsToMap, articles)
            
        setDefaultValues()        
        @db.nav("Data Validation").archIn('Title'    ).as('folder')
                                  .archOut('Contains').as('view')
                                  .archIn('View'     ).as('article')
                                  .solutions(mapResults)        
    
    graphDataFromGraphDB: (dataId, queryId, filters, callback)->
        server = 'http://localhost:1332'
        #server = 'https://tm-graph.herokuapp.com'
        dataId = dataId || 'tm-uno'
        #target = target || 'Logging'
        #graphDataUrl = "#{server}/data/#{dataId}/folder-metadata/filter/tm-search?show=#{queryId}"
        graphDataUrl = "#{server}/data/#{dataId}/query/filter/tm-search?show=#{queryId}"
        if (filters)
            graphDataUrl += "&filters=#{filters}"
        console.log("****:   " + graphDataUrl)
        require('request').get graphDataUrl, (err,response,body)->
            throw err if err
            callback JSON.parse(body)
            
    graphDataFromQAServer: (dataId,callback)->
        #graphDataUrl     = 'http://localhost:1331/graphData.json'
        #graphDataUrl = 'http://levelgraph-test.herokuapp.com/graphData.json'        
        graphDataUrl = 'http://localhost:1332/data/' + dataId + '/tm-search'
        #graphDataUrl = 'https://tm-graph.herokuapp.com/data/' + dataId + '/tm-search' 
        
        console.log("****:   " + graphDataUrl)
        require('request').get graphDataUrl, (err,response,body)->
            throw err if err
            callback JSON.parse(body)
    
 #  mapNodesFromGraphData: (graphData, callback) ->
 #      nodes_by_Id = {}
 #      nodes_by_Is = {}
 #      for node in graphData.nodes
 #          nodes_by_Id[node.id]= { text: node.label, edges: {}}            
 #      
 #      for edge in graphData.edges
 #          edges = nodes_by_Id[edge.from].edges
 #          edges[edge.label] = [] if edges[edge.label] is undefined
 #          edges[edge.label].push(edge.to)
 #
 #          if (edge.label =='is')
 #              nodes_by_Is[edge.to] = [] if nodes_by_Is[edge.to] is undefined
 #              nodes_by_Is[edge.to].push(edge.from)
 #
 #      nodes = {nodes_by_Id:nodes_by_Id, nodes_by_Is:nodes_by_Is }
 #      callback(nodes)
    
    createSearchDataFromGraphData: (graphData,filter_container, filter_query, callback)->
                
        searchData              = {}
        
        setDefaultValues = ->
            searchData.title        = ''
            searchData.containers   = []
            searchData.resultsTitle = ""
            searchData.results      = []
            searchData.filters      = []
            searchData.filter_container = if (filter_container) then filter_container else ''
            searchData.filter_query     = if (filter_query) then filter_query else ''
        
        metadata = {}
        setDefaultValues()
        
        article_Ids = graphData.nodes_by_Id[graphData.nodes_by_Is["Articles"]].edges.contains
        maxArticles = article_Ids.length
        mapArticles = (nodes) =>
            searchData.title        = nodes.nodes_by_Id[nodes.nodes_by_Is["Search"]].text
            
            searchData.resultsTitle = "#{article_Ids.length}/#{maxArticles} results showing"
            for article_Id in article_Ids
                result = { title: null, link: null , id: null, summary: null, score : null }
                article_Node = nodes.nodes_by_Id[article_Id]
                result.title   = article_Node.edges.title
                result.summary = article_Node.edges.summary
                result.guid     = article_Node.edges.guid
                result.id       = article_Id
                searchData.results.push(result)
                
            callback(searchData)
            
        mapMetadata = (nodes) =>
            query_Ids = nodes.nodes_by_Id[nodes.nodes_by_Is["Metadatas"]].edges.contains
            for query_Id in query_Ids
                query_Node = nodes.nodes_by_Id[query_Id]
                filter = {}
                filter.title   = query_Node.text
                filter.results = []
                for metadata_Id in query_Node.edges.contains
                    metadata_Node = nodes.nodes_by_Id[metadata_Id]
                    result = { title : metadata_Node.text ,id: metadata_Id, size: metadata_Node.edges.xref.length}
                    filter.results.push(result)
                    if (filter_query== metadata_Id)
                        article_Ids = []                        
                        for xref_Id in metadata_Node.edges.xref
                            xref_Article = nodes.nodes_by_Id[xref_Id]
                            article_Id   = xref_Article.edges.target
                            article_Ids.push(article_Id)          
                            
                searchData.filters.push(filter)
                
            mapArticles(nodes)
            
        mapContainers = (nodes) =>
            queries_Ids = nodes.nodes_by_Id[nodes.nodes_by_Is["Queries"]].edges.contains
            for queries_Id in queries_Ids
                query_Node = nodes.nodes_by_Id[queries_Id]
                container = { title: query_Node.text, id: queries_Id, size : query_Node.edges.xref.length }
                if (filter_container== queries_Id)
                        article_Ids = []                        
                        for xref_Id in query_Node.edges.xref
                            xref_Article = nodes.nodes_by_Id[xref_Id]
                            article_Id   = xref_Article.edges.target
                            article_Ids.push(article_Id)
                
                
                searchData.containers.push(container)
            mapMetadata(nodes)
                
        mapContainers graphData,
        
module.exports = GraphService