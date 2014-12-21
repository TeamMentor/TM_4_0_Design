fs                = require('fs')
supertest         = require('supertest')
expect            = require('chai').expect
cheerio           = require('cheerio')
app               = require('../../server')
Config            = require('../../Config')
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

describe "functions |", ->

    searchController = new Search_Controller()
    searchController.config.enable_Jade_Cache = true

    it 'searchDataFile', ->
        jsonFile = searchController.searchDataFile()
        expect(fs.existsSync(jsonFile)).to.be.true

    it 'loadSearchData', ->
        searchController.searchData = null
        searchController.loadSearchData()
        searchData = searchController.searchData
        expect(searchData).to.be.an('Object')
        jsonData = JSON.parse(fs.readFileSync(searchController.searchDataFile(), 'utf8'))
        expect(jsonData ).to.be.an('Object')
        expect(searchData).to.deep.equal(jsonData)
        # check that content is the expected one

        expect(searchData.aaaaa       ).to    .equal(undefined)
        expect(searchData.title       ).to.not.equal(undefined)
        expect(searchData.containers  ).to.not.equal(undefined)
        expect(searchData.resultsTitle).to.not.equal(undefined)
        expect(searchData.results     ).to.not.equal(undefined)
        expect(searchData.filters     ).to.not.equal(undefined)

        #containers
        expect(searchData.containers  ).to.not.be.empty
        for container in searchData.containers
            expect(container.title).to.be.an('String')
            expect(container.id   ).to.be.an('String')
            expect(container.size ).to.be.an('Number')

        #results
        expect(searchData.results     ).to.not.be.empty
        for result in searchData.results
            expect(result.title).to.be.an('String')
            expect(result.link ).to.be.an('String')
            expect(result.id   ).to.be.an('String')
            expect(result.score).to.be.an('Number')


        #filters
        expect(searchData.filters     ).to.not.be.empty
        for filter in searchData.filters
            expect(filter.title       ).to.be.an('String')
            expect(filter.results     ).to.not.be.empty
            for result in filter.results
                expect(result.title).to.be.an('String')
                expect(result.size).to.be.an('Number')

    it 'getSearchDataFromRepo', (done)->
      expect(searchController.getSearchDataFromRepo).to.be.an('Function')
      testFile = searchController.defaultDataFile
      searchController.getSearchDataFromRepo testFile, (data)->
         expect(data).to.be.an('string')
         searchData = JSON.parse(data)
         expect(searchData      ).to.be.an('Object')
         expect(searchData.title).to.equal('Data Validation')
         done()

    it 'renderPage (and check content)', ->
      searchController.config.enable_Jade_Cache = false
      console.log ('')
      searchController.searchData = null;                         # renderPage() should call loadSearchData()

      html       = searchController.renderPage()
      searchData = searchController.searchData

      expect(searchData).to.be.an('Object')
      expect(html      ).to.be.an  ('String')
      expect(html      ).to.contain('<!DOCTYPE html>')

      $ = cheerio.load(html)
      expect($).to.be.an('Function')

      #containers
      expect($('#title').html()).to.be.equal(searchData.title)
      expect($('#containers').html()).to.not.equal(null)
      expect($('#containers a').length).to.be.above(0)

      for container in searchData.containers
        element = $("#" + container.id)
        expect(element.html()).to.not.be.null
        expect(element.html()).to.contain(container.title)
        expect(element.html()).to.contain(container.size)

      #results
      expect($('#resultsTitle').html()).to.equal(searchData.resultsTitle)

      for result in searchData.results
          element = $("#" + result.id)
          expect(element.html()             ).to.not.be.null
          expect(element.attr('id'  )       ).to.equal(result.id)
          expect(element.attr('href')       ).to.equal(result.link)
          expect(element.find('h4'  ).html()).to.equal(result.title)
          expect(element.find('p'   ).html()).to.equal(result.summary)

      #filters
      mappedFilters = {}
      for filter in searchData.filters
          mappedFilters[filter.title] = filter

      expect($('#filters'     ).html()).to.not.equal(null)
      expect($('#filters h3'  ).html()).to.equal('Filters')
      expect($('#filters form').html()).to.not.equal(null)
      expect($('#filters form .form-group').html()).to.not.equal(null)

      formGroups = $('#filters form .form-group')
      expect(formGroups.length).to.equal(searchData.filters.length)
      for formGroup in formGroups
          title = $(formGroup).find('h5').html()
          expect(title).to.be.an('String')
          mappedFilter = mappedFilters[title]
          expect(mappedFilter).to.be.an('Object')
          formGroupHtml = $(formGroup).html()
          for result in mappedFilter.results
              expect(formGroupHtml).to.contain(result.title)
              expect(formGroupHtml).to.contain(result.size)

    #console.log(.length)
        #for filter in searchData.filters


describe "routes |", ->
        
  @.timeout(3500)

  app.config.enable_Jade_Cache = true

  it '/search', (done) ->
      supertest(app).get('/search')
                    .expect(200)
                    .end (error, response)->
                          $ = cheerio.load(response.text)
                          expect($('#title').html()).to.equal('Data Validation')
                          done()

  it '/search/:file', (done) ->
      file = 'Input_Validation'
      url  = "/search/#{file}"
      supertest(app).get(url)
                    .expect(200)
                    .end (error, response)->
                          $ = cheerio.load(response.text)
                          expect($('#title').html()).to.equal('Input Validation')
                          done()

  it '/search.json', (done) ->
      searchController = new Search_Controller()
      searchData       = JSON.stringify(searchController.loadSearchData().searchData, null, " ")
      supertest(app).get('/search.json')
                    .expect('Content-Type', /json/)
                    .expect(200, searchData , done)

  it '/graph', (done)->
      supertest(app).get('/graph')
                    .expect(200)
                    .end (error, response)->
                          $ = cheerio.load(response.text)
                          #console.log(response.text)
                          expect($('#title').html()).to.equal('Data from Graph')
                          done()