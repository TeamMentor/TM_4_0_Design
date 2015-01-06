fs                = require('fs')
supertest         = require('supertest')
expect            = require('chai').expect
cheerio           = require('cheerio')
app               = require('../../server')
Config            = require('../../misc/Config')
Search_Controller = require('../../controllers/Search-Controller')

require('fluentnode')

describe "controllers | test-Search-Controller |", ->
    
  @.timeout(3500)

  it "Ctor values", ->
      expect(Search_Controller).to.be.an('Function')

      req    = {}
      res    = {}
      config = new Config()
      searchController = new Search_Controller(req, res, config)

      expect(searchController             ).to.be.an     ('Object'  )
      expect(searchController.req         ).to.be.an     ('Object'  )
      expect(searchController.res         ).to.be.an     ('Object'  )
      expect(searchController.config      ).to.be.an     ('Object'  )
      expect(searchController.config      ).to.be.an     ('Object'  )
      expect(searchController.jade_Service).to.be.an     ('Object'  )
      expect(searchController.abc         ).to.not.be.an ('Object'  )

      expect(searchController.req         ).to.equal     (req       )
      expect(searchController.res         ).to.equal     (res       )
      expect(searchController.config      ).to.equal     (config    )
      expect(searchController.searchData  ).to.equal     (null      )
      expect(searchController.jade_Page   ).to.equal     ('/source/jade/user/search.jade')

      expect(searchController.defaultUser    ).to.be.an('String')
      expect(searchController.defaultRepo    ).to.be.an('String')
      expect(searchController.defaultFolder  ).to.be.an('String')
      expect(searchController.defaultDataFile).to.be.an('String')

      expect(searchController.renderPage ).to.be.an('Function')

      expect(new Search_Controller().config).to.deep.equal(new Config())


  searchController = new Search_Controller()
  searchController.config.enable_Jade_Cache = true

  it 'showSearchFromGraph', (done)->
    req    = { params: queryId : 'Logging'}
    res    =
              send: (html)->
                  html.assert_Is_String()
                  done()
    config = new Config()
    searchController = new Search_Controller(req, res, config)
    searchController.showSearchFromGraph()

  it 'showSearchFromGraph (with filter)', (done)->
    req    = { params: {queryId : 'Logging' , filters:'abc'}}
    res    =
        send: (html)->
            html.assert_Is_String()
            done()
    config = new Config()
    searchController = new Search_Controller(req, res, config)
    searchController.showSearchFromGraph()

  it  'showMainAppView', (done)->
    req    = { params: queryId : 'Logging'}
    res    =
        render: (jadePage,viewModel)->
            #html.assert_Is_String()
            jadePage.assert_Is('source/jade/user/main.jade')
            viewModel.assert_Is({})
            done()
    config = new Config()
    searchController = new Search_Controller(req, res, config)
    searchController.showMainAppView()

  it 'showArticle', (done)->
    req = { params: queryId : 'Logging'}
    res =
        redirect: (url)->
            url.assert_Is('https://tmdev01-uno.teammentor.net/undefined')
            done()
    config = new Config()
    searchController = new Search_Controller(req, res, config)
    searchController.showArticle()
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
