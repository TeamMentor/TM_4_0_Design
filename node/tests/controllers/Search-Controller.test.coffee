fs                = require('fs')
supertest         = require('supertest')
expect            = require('chai').expect
cheerio           = require('cheerio')
app               = require('../../server')
Config            = require('../../misc/Config')
Search_Controller = require('../../controllers/Search-Controller')
Express_Service   = require('../../services/Express-Service')


describe "controllers | test-Search-Controller |", ->
    
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
        @.jade_Service      .assert_Instance_Of require('../../services/Jade-Service')
        @.teamMentor_Service.assert_Instance_Of require('../../services/TeamMentor-Service')
        @.defaultUser       .assert_Is 'TMContent'
        @.defaultRepo       .assert_Is 'TM_Test_GraphData'
        @.defaultFolder     .assert_Is '/SearchData/'
        @.defaultDataFile   .assert_Is 'Data_Validation'

      using new Search_Controller(),->
        @.config.assert_Is(new Config())


  it 'showSearchFromGraph', (done)->
    req    = { params: queryId : 'Logging'}
    res    =
              send: (html)->
                  html.assert_Is_String()
                  done()
    config = new Config()
    using new Search_Controller(req, res, config),->
      @.showSearchFromGraph()

  it 'showSearchFromGraph (with filter)', (done)->
    req    = { params: {queryId : 'Logging' , filters:'abc'}}
    res    =
        send: (html)->
            html.assert_Is_String()
            done()
    using new Search_Controller(req, res),->
      @.showSearchFromGraph()

  it  'showMainAppView', (done)->
    req    = { params: queryId : 'Logging'}
    res    =
        render: (jadePage,viewModel)->
            #html.assert_Is_String()
            jadePage.assert_Is('source/jade/user/main.jade')
            #viewModel.assert_Is({recentArticles:[]})
            done()
    using new Search_Controller(req, res),->
      @.showMainAppView()

  xit 'recentArticles recentArticles_add', (done)->
    id = 'aaaaaaaa_'.add_5_Letters()
    title= 'an title_'.add_5_Letters()
    req    = { session: {} }
    using new Search_Controller(req),->
      assert_Is_Undefined @.req.session.recent_Articles
      @.recentArticles_add(id, title)
      @.req.session.recent_Articles.assert_Is_Array()
                   .first()        .assert_Is {id:id, title:title}
      @.recentArticles_add('2', 'abc'); @.req.session.recent_Articles.assert_Size_Is 2
      @.recentArticles_add(id , title); @.req.session.recent_Articles.assert_Size_Is 3

      tm_35_Server = @.teamMentor_Service.tm_35_Server

      using @.recentArticles(), ->
        @.assert_Size_Is 3
        @.first() .assert_Is { href: tm_35_Server + '/' + id , title: title }
        @.second().assert_Is { href: tm_35_Server + '/' + '2', title: 'abc' }
        done()

  xit 'showArticle', (done)->
    req = {
            params: queryId : 'Logging'
            session: {}
          }
    res =
        redirect: (url)->
            url.assert_Is('https://tmdev01-uno.teammentor.net/undefined')
            done()
    using new Search_Controller(req, res),->
      @.showArticle()



  describe 'using Express_Service | ',->

    tmpSessionFile = './_tmp_Session'

    after ->
      tmpSessionFile.assert_File_Deleted()

    using_Express_Service_With_Search_Controller = (callback)->
      using new Express_Service(),->
        @.add_Session(tmpSessionFile)
        @.loginEnabled = false
        Search_Controller.registerRoutes @.app, @

        @.open_Article = (id, title, callback)=>
          supertest(@.app)
          .get("/article/view/#{id}/#{title}")
          .end (err,res)=>
            callback res

        callback.apply @

    it 'Create Express_Service and register Search_Controller routes', (done)->
      using new Express_Service(),->
        @.add_Session()
        @.app._router.stack.assert_Size_Is 3
        Search_Controller.registerRoutes @.app
        @.app._router.stack.assert_Size_Is 9
        supertest(@.app)
          .get('/user/main.html')
          .end (err,res)->
            res.text.assert_Contains('<li><a href="/guest/about.html">About</a></li>')
            done()

    xit 'User views an article which is captured on the recent_Articles list', (done)->

      using_Express_Service_With_Search_Controller ()->

        id    = 'this-is-an-guid'
        title = 'c'
        @.open_Article id, title, (res)=>
            res.text.assert_Contains ['Moved Temporarily. Redirecting to','this-is-an-guid']
            @.expressSession.db.find {}, (err,sessionData)->
              sessionData.first().data.recent_Articles.assert_Is [ { id: 'this-is-an-guid', title: 'c' } ]
              done()

    xit 'open multiple articles,  open article/viewed.json', (done)->
      using_Express_Service_With_Search_Controller ()->
        @.open_Article 'a', 'title 1', (res)=>
          @.open_Article 'b', 'title 2', (res)=>
            @.open_Article 'b', 'title 2', (res)=>
              @.open_Article 'c', 'title 2', (res)=>
                supertest(@.app).get('/article/viewed.json')
                  .end (err, res)->
                    data = JSON.parse res.text
                    data.assert_Size_Is_Bigger_Than(3)
                    done()



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
