require('fluentnode')
fs             = require('fs'           )
http           = require('http'         )
expect         = require('chai'         ).expect
spawn          = require('child_process').spawn
Graph_Service  = require('./../../services/Graph-Service')
Server         = http.Server

Server::respond_With_Request_Url = (value)->
  delete @._events.request
  simple_Response = (req, res) ->
    res.writeHead(200, {'Content-Type': 'application/json'})
    data = { url: req.url}
    res.end(data.json_Str())
  @.addListener('request', simple_Response)
  @


describe 'services | Graph-Service.test |', ->

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

  it 'query_From_Text_Search (to_ids returns a valid mapping)', (done)->
    mappings = {'aaa': id :'123'.add_5_Letters()}
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



# Move code below to GraphDB since those test have access to library data

#   it 'loadTestData', (done)->
#       expect(graphService.loadTestData).to.be.an('Function')
#       graphService.loadTestData () ->
#                                           expect(graphService.data).to.not.be.empty
#                                           expect(graphService.data.length).to.be.above(50)
#                                           #graphService.closeDb()
#                                           done()
#
#   it 'alldata', (done)->
#       expect(graphService.allData).to.be.an('Function')
#       graphService.allData  (err, data) ->
#                                               expect(data.length).to.equal(graphService.data.length)
#                                               done()
#   it 'query', (done)->
#       expect(graphService.query).to.be.an('Function')
#
#       items = [{ key : "subject"  , value: "bcea0b7ace25" , hasResults:true }
#                { key : "subject"  , value: "...."         , hasResults:false}
#                 { key : "predicate", value: "View"         , hasResults:true }
#                 { key : "predicate", value: "...."         , hasResults:false}
#                 { key : "object"   , value: "Design"       , hasResults:true }]
#        #items = []
#        checkItem = ->
#            if(items.empty())
#                done()
#            else
#                item = items.pop()
#                graphService.query item.key, item.value, (err, data)->
#                    if (item.hasResults)
#                        expect(data).to.not.be.empty
#                        expect(JSON.stringify(data)).to.contain(item.key)
#                        expect(JSON.stringify(data)).to.contain(item.value)
#                    else
#                        expect(data).to.be.empty
#                    checkItem()
#        checkItem()
#
     
#    it 'createSearchData' , (done)->
#
#        viewName          = 'Data Validation'
#        container_Title   = 'Perform Validation on the Server'
#        container_Id      = '4eef2c5f-7108-4ad2-a6b9-e6e84097e9e0'
#        container_Size    = 3
#        resultsTitle      = '8/8 results showing'
#        result_Title      = 'Client-side Validation Is Not Relied On'
#        result_Link       = 'https://tmdev01-uno.teammentor.net/9607b6e3-de61-4ff7-8ef0-9f8b44a5b27d'
#        result_Id         = '9607b6e3-de61-4ff7-8ef0-9f8b44a5b27d'
#        result_Summary    = 'Verify that the same or more rigorous checks are performed on the server as
#                             on the client. Verify that client-side validation is used only for usability
#                             and to reduce the number of posts to the server.'
#        result_Score      = 0
#        view_Title        = 'Technology'
#        view_result_Title = 'ASP.NET 4.0'
#        view_result_Size  = 1
#
#        checkSearchData = (data)->
#            #console.log(data)
#            expect(data             ).to.be.an('Object')
#            expect(data.title       ).to.be.an('String')
#            expect(data.containers  ).to.be.an('Array' )
#            expect(data.resultsTitle).to.be.an('String')
#            expect(data.results     ).to.be.an('Array' )
#            expect(data.filters     ).to.be.an('Array' )
#
#            expect(data.title                   ).to.equal(viewName)
#            expect(data.containers.first().title).to.equal(container_Title)
#            expect(data.containers.first().id   ).to.equal(container_Id   )
#            expect(data.containers.first().size ).to.equal(container_Size )
#            expect(data.resultsTitle            ).to.equal(resultsTitle   )
#            expect(data.results.first().title   ).to.equal(result_Title)
#            expect(data.results.first().link    ).to.equal(result_Link)
#            expect(data.results.first().id      ).to.equal(result_Id)
#            expect(data.results.first().summary ).to.equal(result_Summary)
#            expect(data.results.first().score   ).to.equal(result_Score)
#
#            firstFilter = data.filters.first()
#            expect(firstFilter.title                ).to.equal(view_Title)
#            expect(firstFilter.results              ).to.be.an('Array' )
#            expect(firstFilter.results.first().title).to.equal(view_result_Title)
#            expect(firstFilter.results.first().size ).to.equal(view_result_Size)
#
#            done()
#
#        graphService.createSearchData viewName, checkSearchData