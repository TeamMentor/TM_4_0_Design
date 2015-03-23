require('fluentnode')
fs             = require('fs'           )
http           = require('http'         )
expect         = require('chai'         ).expect
spawn          = require('child_process').spawn
Graph_Service  = require('./../../src/services/Graph-Service')
Server         = http.Server

describe '| services | Graph-Service.test |', ->

  test_Port    = 45566 + Math.floor((Math.random() * 1000) + 1)
  test_Ip      = '127.0.0.1'
  test_Data    = 'mocked server'
  test_Server  = "http://#{test_Ip}:#{test_Port}"
  server       = null
  graphService = null

  before (done)->
    test_Server.assert_Contains(test_Ip).assert_Contains(test_Port)
    server = http.createServer(null)
    server.listen_OnPort_Saying test_Port, test_Data, ()=>
      graphService  = new Graph_Service( { server: test_Server})
      done()

  after (done)->
    server.close_And_Destroy_Sockets ()->
      done()

  it 'article_Html (bad id)', (done)->
    graphService.article_Html null,  (data)=>
      data.assert_Is ''
      done()

  it 'article_Html (good id)', (done)->
    server.respond_With_Request_Url()
    article_Id = 'abc_'.add_5_Letters()
    graphService.article_Html article_Id,  (data)=>
      data.url.assert_Is "/data/article_Html/#{article_Id}"
      done()

  it 'article', (done)->
    server.respond_With_Request_Url()
    ref = 'abc_'.add_5_Letters()
    graphService.article ref, (data)=>
      data.url.assert_Is "/data/article/#{ref}"
      done()

  it 'articles', (done)->
    graphService.articles (data)=>
      data.assert_Is { url: '/data/articles/' }
      done()


  it 'graphDataFromGraphDB (no queryId and no filters)', (done)->
    graphService.graphDataFromGraphDB null, null,  (searchData)=>
      searchData.assert_Is {}
      done()

  it 'graphDataFromGraphDB (with queryId and no filters)', (done)->
    server.respond_With_Request_Url()

    query_Id = 'AAAAAA'.add_5_Letters()
    graphService.graphDataFromGraphDB query_Id, null,  (data)=>
      data.url.assert_Is "/data/query_tree/#{query_Id}"
      server.respond_With_String_As_Text(null)
      graphService.graphDataFromGraphDB query_Id, null,  (data)=>
        data.assert_Is {}
        done()

  it 'graphDataFromGraphDB (with queryId no filters)', (done)->
    server.respond_With_Request_Url()

    query_Id = 'AAAAAA'.add_5_Letters()
    filters  = 'AAAAAA'.add_5_Letters()
    graphService.graphDataFromGraphDB query_Id, filters,  (data)=>
      data.url.assert_Is "/data/query_tree_filtered/#{query_Id}/#{filters}"
      done()

  it 'graphDataFromGraphDB (with queryId no filters)', (done)->
    server.respond_With_Request_Url()

    query_Id = 'abc_'.add_5_Letters()
    filters  = 'abc_'.add_5_Letters()
    graphService.graphDataFromGraphDB query_Id, filters,  (data)=>
      data.url.assert_Is "/data/query_tree_filtered/#{query_Id}/#{filters}"
      done()

  it 'library_Query',(done)->
    graphService.library_Query (data)->
      data.url.assert_Is '/data/library_Query'
      done()

  it 'resolve_To_Ids', (done)->
    values = 'abc_'.add_5_Letters()
    graphService.resolve_To_Ids values,  (data)=>
      data.url.assert_Is "/convert/to_ids/#{values}"
      done()

  it 'root_Queries', (done)->
    graphService.root_Queries (data)=>
        data.url.assert_Is "/data/query_tree/Root-Queries"
        done()

  it 'query_From_Text_Search (bad text)', (done)->
    graphService.query_From_Text_Search null,  (data)=>
      assert_Is_Null data
      done()

  it 'query_From_Text_Search (to_ids returns a valid mapping with "query-")', (done)->
    mappings = {'aaa': id :'query-'.add_5_Letters()}
    server.respond_With_Object_As_Json mappings
    text = 'abc_'.add_5_Letters()
    graphService.query_From_Text_Search text,  (data)=>
      data.assert_Is mappings.aaa.id
      done()

  it 'query_From_Text_Search (to_ids returns a string)', (done)->
    server.respond_With_Request_Url()
    text = 'abc_'.add_5_Letters()
    graphService.query_From_Text_Search text,  (data)=>
      data.json_Parse().url.assert_Is "/search/query_from_text_search/#{text}"
      done()

   it 'node_Data (bad id)', (done)->
    graphService.node_Data null,  (data)=>
      data.assert_Is ''
      done()

  it 'node_Data (good id)', (done)->
    server.respond_With_Request_Url()
    article_Id = 'abc_'.add_5_Letters()
    graphService.node_Data article_Id,  (data)=>
      data.assert_Is "/data/id/#{article_Id}"
      done()

  it 'node_Data (good id, bad response)', (done)->
    server.respond_With_String_As_Text 'aaaa'
    article_Id = 'abc_'.add_5_Letters()
    graphService.node_Data article_Id,  (data)=>
      data.assert_Is {}
      done()

  it 'server_Online (on live server)', (done)->
    using graphService,->
      @.server.assert_Is test_Server
      @.server_Online (online)->
        online.assert_True()
        done()

  it 'server_Online (on not live server)', (done)->
    using new Graph_Service({ server: 'http://aaaa.bbbb.ccc.ddd'}),->
      @.server_Online (online)->
        online.assert_False()
        done()

  it 'Issue 595 - Bug in GraphDB Service resolve_To_Ids method', (done)->
    graphService.resolve_To_Ids undefined,  (data)=>
      data.assert_Is {}
      done()