fs                = require('fs')
supertest         = require('supertest')
expect            = require('chai').expect
cheerio           = require('cheerio')
Config            = require('../../src/misc/Config')
Search_Controller = require('../../src/controllers/Search-Controller')
Express_Service   = require('../../src/services/Express-Service')


describe "| controllers | Search-Controller.test |", ->

  @.timeout(3500)

  it "constructor", ->
      expect(Search_Controller).to.be.an('Function')

      req    = {}
      res    = {}
      config = new Config()

      using new Search_Controller(req, res, config), ->
        assert_Is_Null @.searchData
        @.req               .assert_Is req
        @.res               .assert_Is res
        @.config            .assert_Is config
        @.jade_Page         .assert_Is '/source/jade/user/search.jade'
        @.jade_Service      .assert_Instance_Of require('../../src/services/Jade-Service')
        @.graph_Service     .assert_Instance_Of require('../../src/services/Graph-Service')
        @.defaultUser       .assert_Is 'TMContent'
        @.defaultRepo       .assert_Is 'TM_Test_GraphData'
        @.defaultFolder     .assert_Is '/SearchData/'
        @.defaultDataFile   .assert_Is 'Data_Validation'
        @.urlPrefix         .assert_Is 'show'
        assert_Is_Null @.searchData

      using new Search_Controller(),->
        @.config.assert_Is(new Config())

  it 'renderPage', (done)->
    using new Search_Controller(),->
      html = @.renderPage()
      $    = cheerio.load html
      $('#results' ).html().assert_Is_String()
      $('#articles').html().assert_Is_String()
      done()

  it 'get_Navigation', (done)->
    using new Search_Controller(),->
      @.graph_Service.resolve_To_Ids = (query_Id,callback)->
        callback { query_Id : { id: 'id-123', title: 'title-123'}}
      @.get_Navigation 'query-id-123', (data)->
        data.assert_Is [ { href: '/show/query_Id', title: 'title-123', id: 'id-123' } ]
        done()


  it 'showSearchFromGraph', (done)->
    req    = { params: queryId : 'query-id'}
    res    =
              send: (html)->
                  html.assert_Is_String()
                  done()
    config = new Config()
    using new Search_Controller(req, res, config),->
      @.showSearchFromGraph()


  it 'show_Root_Query',(done)->
    test_Query_Id = 'query-'.add_5_Letters()
    test_Title    = 'query-title'.add_5_Letters()
    req    = { params: queryId : 'query-id'}
    res    =
              send: (html)->
                html.assert_Contains ('An error occurred')
                done()

    using new Search_Controller(req,res),->

      @.graph_Service =
        library_Query: (callback)->
          callback  { queryId  : test_Query_Id}
        resolve_To_Ids: (query_Id,callback)->
          query_Id.assert_Is test_Query_Id
          callback { query_Id : { id: test_Query_Id, title: test_Title }}
        graphDataFromGraphDB: (query_Id, filters, callback)->
          query_Id.assert_Is test_Query_Id
          callback {title:test_Title }

      @show_Root_Query()

  it 'showMainAppView', (done)->
    req    = { params: queryId : 'Logging', session: {}}
    res    =
        render: (jadePage,viewModel)->
            jadePage.assert_Is('source/jade/user/main.jade')
            done()
    express_Service =
      session_Service :
        user_Data: (session, callback) ->
          callback {}

    using new Search_Controller(req, res),->
      @.express_Service = express_Service
      @.showMainAppView()


  describe 'showSearchFromGraph |', ->

    graph_Service = (on_GraphDataFromGraphDB)->
        resolve_To_Ids: (query_Id,callback)->
          callback { query_Id : { id: 'id-123', title: 'title-123'}}
        graphDataFromGraphDB: (query_Id, filters, callback)->
          searchData = on_GraphDataFromGraphDB(query_Id, filters)
          callback(searchData)

    it 'no query-name and filter (searchData is null)', (done)->
      req    = { params: {}}
      res    =
        send: (html)->
          $    = cheerio.load html
          $('#results').html().assert_Is_String()
          $('#articles').html().assert_Is_String()
          done()


      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service ()->
          return null

        @.showSearchFromGraph()

    it 'with query-name and filter (searchData is null)', (done)->
      req    = { params: {queryId : 'query-name' , filters:'filters-abc'}}
      res    =
        send: (html)->
          $    = cheerio.load html
          $('#results' ).text().assert_Is ''
          $('#articles').text().assert_Is ''
          done()


      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service ()->
          return null

        @.showSearchFromGraph()

    it 'with query-name no filter (valid searchData)', (done)->
      req    = { params: {queryId : 'query-name' , filters:null}}
      res    =
        send: (html)->
          $    = cheerio.load html
          $('#resultsTitle').text().assert_Is 'Showing 1 articles' + 'Showing 1 articles'
          $('#results'     ).html().contains('Showing 1 articles')
          $('#articles #list-view-article').html().assert_Is_String()
          $('#list-view-article #result-id-1 h4').html().assert_Is 'result-title-1'
          done()

      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service (query_Id, filters)->
          query_Id.assert_Is 'id-123'
          return { results: [ {id:'result-id-1', title:'result-title-1'}]}

        @.showSearchFromGraph()

    it 'with query-name and filter (valid searchData)', (done)->
      req    = { params: {queryId : 'query-name' , filters:'abc'}}
      res    =
        send: (html)->
          $    = cheerio.load html
          $('#resultsTitle').text().assert_Is 'Showing 1 articles' + 'Showing 1 articles'
          $('#results'     ).html().contains('Showing 1 articles')
          $('#articles #list-view-article').html().assert_Is_String()
          $('#list-view-article #result-id-1 h4').html().assert_Is 'result-title-1'
          $('#activeFilter').html().assert_Is 'title-123<span class="close"><a href="/show/query_Id/abc">x</a></span>'
          done()

      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service (query_Id, filters)->
          query_Id.assert_Is 'id-123'
          return { results: [ {id:'result-id-1', title:'result-title-1'}]}

        @.showSearchFromGraph()


  describe 'search |', ->

    graph_Service = (on_Query_From_Text_Search,on_GraphDataFromGraphDB)->
      query_From_Text_Search: (text, callback)->
        callback on_Query_From_Text_Search(text)
      resolve_To_Ids: (query_Id,callback)->
        callback { query_Id : { id: 'id-123', title: 'title-123'}}
      graphDataFromGraphDB: (query_Id, filters, callback)->
        callback on_GraphDataFromGraphDB(query_Id, filters)

    it 'no search text and null searchData', (done)->
      req    = { params: {}, session:{}}
      res    =
        send: (html)->
          cheerio.load html.assert_Contains 'results'
          done()

      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service (()-> null) , (()-> null )
        @.search()

    it 'no search text but {} as searchData', (done)->
      req    = { params: {}, session:{}}
      res    =
        send: (html)->
          html.assert_Contains 'results'
          done()

      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service (()-> '') , (()-> {} )
        @.search()

    it 'search text but {} as searchData', (done)->
      req    = { session:{}, query: text: 'text-search' }
      res    =
        send: (html)->
          html.assert_Contains 'results'
          $ = cheerio.load html
          $('#search-input').attr().assert_Is { id: 'search-input' }
          $('#results p').text().assert_Is 'No ResultsPlease try again' + 'No ResultsPlease try again'
          done()

      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service (()-> '') , (()-> {} )
        @.search()

    it 'search text, no filter, valid searchData', (done)->
      req    = { session:{}, query: text: 'text-search' }
      res    =
        send: (html)->
          html.assert_Contains 'results'
          $ = cheerio.load html
          $('#articles #list-view-article #result-id').attr().assert_Is { href: '/article/result-id/title-id', id: 'result-id' }
          $('#list-view-article h4').html().assert_Is 'title-id'
          $('#activeFilter').text().assert_Is ''
          done()

      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service (()-> '') , (()-> { id:'search-id', results: [{id:'result-id', title:'title-id'}]} )
        @.search()

    it 'search text, filter, valid searchData', (done)->
      req    = { session:{}, query: text: 'text-search' , filters: '/filter-text'}
      res    =
        send: (html)->
          html.assert_Contains 'results'
          $ = cheerio.load html
          $('#articles #list-view-article #result-id').attr().assert_Is { href: '/article/result-id/title-id', id: 'result-id' }
          $('#list-view-article h4').html().assert_Is 'title-id'
          $('#activeFilter').text().assert_Is 'title-123x' + 'title-123x'
          done()

      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service (()-> '') , (()-> { id:'search-id', results: [{id:'result-id', title:'title-id'}]} )
        @.search()

    it 'search using url', (done)->
      req    = { session:{}, query: {}, params: text: 'text-search' }
      res    =
        send: (html)->
          html.assert_Contains 'results'
          $ = cheerio.load html
          $('#articles #list-view-article #result-id').attr().assert_Is { href: '/article/result-id/title-id', id: 'result-id' }
          done()

      using new Search_Controller(req, res),->
        @.graph_Service = graph_Service (()-> '') , (()-> { id:'search-id', results: [{id:'result-id', title:'title-id'}]} )
        @.search_Via_Url()


  describe 'using Express_Service | ',->

    tmpSessionFile = './_tmp_Session'

    after ->
      tmpSessionFile.assert_File_Deleted()

    it 'Create Express_Service and register Search_Controller routes', (done)->
      using new Express_Service(),->
        @.add_Session()
        @.app._router.stack.assert_Size_Is 3
        Search_Controller.register_Routes @.app,@
        @.app._router.stack.assert_Size_Is 10
        supertest(@.app)
          .get('/user/main.html')
          .end (err,res)->
            res.text.assert_Contains('<li><a id="nav-about" href="/guest/about.html">About</a></li>')
            done()

    it '/user/main.html', (done)->
      using new Express_Service(),->
        @.add_Session(tmpSessionFile)
        @.loginEnabled = false
        @.set_Views_Path()
        Search_Controller.register_Routes @.app, @

        supertest(@.app).get("/user/main.html")
                        .end (err,res)=>
                          assert_Is_Null err
                          res.text.contains 'Top Articles'
                          done()

  # using_Express_Service_With_Search_Controller = (callback)->
  #   using new Express_Service(),->
  #     @.add_Session(tmpSessionFile)
  #     @.loginEnabled = false
  #     Search_Controller.registerRoutes @.app, @

  #     @.open_Article = (id, title, callback)=>
  #       supertest(@.app)
  #       .get("/article/view/#{id}/#{title}")
  #       .end (err,res)=>
  #         callback res

  #     callback.apply @

#
#      using_Express_Service_With_Search_Controller ()->
#
#        id    = 'this-is-an-guid'
#        title = 'c'
#        @.open_Article id, title, (res)=>
#            res.text.assert_Contains ['Moved Temporarily. Redirecting to','this-is-an-guid']
#            @.expressSession.db.find {}, (err,sessionData)->
#              sessionData.first().data.recent_Articles.assert_Is [ { id: 'this-is-an-guid', title: 'c' } ]
#              done()


#    xit 'User views an article which is captured on the recent_Articles list', (done)->
#
#      using_Express_Service_With_Search_Controller ()->
#
#        id    = 'this-is-an-guid'
#        title = 'c'
#        @.open_Article id, title, (res)=>
#            res.text.assert_Contains ['Moved Temporarily. Redirecting to','this-is-an-guid']
#            @.expressSession.db.find {}, (err,sessionData)->
#              sessionData.first().data.recent_Articles.assert_Is [ { id: 'this-is-an-guid', title: 'c' } ]
#              done()
#
#    xit 'open multiple articles,  open article/viewed.json', (done)->
#      using_Express_Service_With_Search_Controller ()->
#        @.open_Article 'a', 'title 1', (res)=>
#          @.open_Article 'b', 'title 2', (res)=>
#            @.open_Article 'b', 'title 2', (res)=>
#              @.open_Article 'c', 'title 2', (res)=>
#                supertest(@.app).get('/article/viewed.json')
#                  .end (err, res)->
#                    data = JSON.parse res.text
#                    data.assert_Size_Is_Bigger_Than(3)
#                    done()
#


  #to redo once we have better offline content mapped to this
# xit 'renderPage (and check content)', ->
#   searchController.config.enable_Jade_Cache = false
#   console.log ('')
#   searchController.searchData = null;                         # renderPage() should call loadSearchData()

#   html       = searchController.renderPage()
#   searchData = searchController.searchData

#   expect(searchData).to.be.an('Object')
#   expect(html      ).to.be.an  ('String')
#   expect(html      ).to.contain('<!DOCTYPE html>')

#   $ = cheerio.load(html)
#   expect($).to.be.an('Function')

#   #containers
#   expect($('#title').html()).to.be.equal(searchData.title)
#   expect($('#containers').html()).to.not.equal(null)
#   expect($('#containers a').length).to.be.above(0)

#   for container in searchData.containers
#     element = $("#" + container.id)
#     expect(element.html()).to.not.be.null
#     expect(element.html()).to.contain(container.title)
#     expect(element.html()).to.contain(container.size)

#   #results
#   expect($('#resultsTitle').html()).to.equal(searchData.resultsTitle)

#   for result in searchData.results
#       element = $("#" + result.id)
#       expect(element.html()             ).to.not.be.null
#       expect(element.attr('id'  )       ).to.equal(result.id)
#       expect(element.attr('href')       ).to.equal(result.link)
#       expect(element.find('h4'  ).html()).to.equal(result.title)
#       expect(element.find('p'   ).html()).to.equal(result.summary)

#   #filters
#   mappedFilters = {}
#   for filter in searchData.filters
#       mappedFilters[filter.title] = filter

#   expect($('#filters'     ).html()).to.not.equal(null)
#   expect($('#filters h3'  ).html()).to.equal('Filters')
#   expect($('#filters form').html()).to.not.equal(null)
#   expect($('#filters form .form-group').html()).to.not.equal(null)

#   formGroups = $('#filters form .form-group')
#   expect(formGroups.length).to.equal(searchData.filters.length)
#   for formGroup in formGroups
#       title = $(formGroup).find('h5').html()
#       expect(title).to.be.an('String')
#       mappedFilter = mappedFilters[title]
#       expect(mappedFilter).to.be.an('Object')
#       formGroupHtml = $(formGroup).html()
#       for result in mappedFilter.results
#           expect(formGroupHtml).to.contain(result.title)
#           expect(formGroupHtml).to.contain(result.size)
