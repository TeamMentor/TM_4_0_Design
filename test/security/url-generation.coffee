Graph_Service  = require './../../src/services/Graph-Service'
http           = require 'http'

describe '| security | url-generation |', ->

  test_Port    = null
  test_Ip      = '127.0.0.1'
  test_Server  = null
  server       = null
  graphService = null

  payload = 'sdfasdf - %3Casdf98y345£$%@$£^£$%& ../..\\ " < > ! = '

  before (done)->
    test_Port   = (10000).random().add 10000
    test_Server = "http://#{test_Ip}:#{test_Port}"

    test_Server.assert_Contains(test_Ip).assert_Contains(test_Port)
    graphService  = new Graph_Service( { server: test_Server})
    server = http.createServer(null)
                 .listen_OnPort_Saying test_Port, "I'm here", ->
                    test_Server.append('/aaa/bbb').GET (data)->
                      data.assert_Is "I'm here"
                      server.respond_With_Request_Url()
                      test_Server.append('/aaa/bbb').GET (data)->
                        data.assert_Is {"url":"/aaa/bbb"}.json_Str()
                        done()

  after (done)->
    server.close_And_Destroy_Sockets ()->
      done()

  it 'graphDataFromGraphDB (no filter)', (done)->
    graphService.graphDataFromGraphDB payload, null,  (data)=>
      data.url.assert_Is "/data/query_tree/#{payload.url_Encode()}"
      done()

  it 'graphDataFromGraphDB (with filter)', (done)->
    graphService.graphDataFromGraphDB payload, payload,  (data)=>
      data.url.assert_Is "/data/query_tree_filtered/#{payload.url_Encode()}/#{payload.url_Encode()}"
      done()

  it 'resolve_To_Ids', (done)->
    graphService.resolve_To_Ids payload,  (data)=>
      data.url.assert_Is "/convert/to_ids/#{payload.url_Encode()}"
      done()

  it 'root_Queries', (done)->
    graphService.root_Queries (data)=>
      data.url.assert_Is "/data/query_tree/Root-Queries"
      done()

  it 'query_From_Text_Search', (done)->
    graphService.query_From_Text_Search payload,  (data)=>
      data.json_Parse().url.assert_Is "/search/query_from_text_search/#{payload.url_Encode()}"
      done()

  it 'article_Html', (done)->
    graphService.article_Html payload,  (data)=>
      data.url.assert_Is "/data/article_Html/#{payload.url_Encode()}"
      done()

  it 'node_Data', (done)->
    graphService.node_Data payload,  (data)=>
      data.assert_Is "/data/id/#{payload.url_Encode()}"
      done()
