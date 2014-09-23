fs                = require('fs')
supertest         = require('supertest')
expect            = require('chai').expect
cheerio           = require('cheerio')
app               = require('../../server')
Config            = require('../../Config')
Search_Controller = require('../../controllers/Search-Controller')

describe "controllers | test-Search-Controller |", ->

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
        expect(searchController.searchData  ).to.equal     (null       )
        expect(searchController.jade_Page   ).to.equal     ('/source/html/search/main.jade')
        
        expect(searchController.showSearch ).to.be.an('Function')
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
         
         it 'renderPage (and check ', ->
            
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


    describe "routes |", ->
    
        app.config.enable_Jade_Cache = true
        
        it '/search', (done) ->
            supertest(app).get('/search')
                          .expect(200, done)
                          
          ###
          .end(function(error, response)
                {
                    expect(response.headers         ).to.be.an('Object');
                    expect(response.headers.location).to.be.an('String');
                    expect(response.headers.location).to.equal(gitHub_Path + test_image);
                    check_That_Image_Exists(response.headers.location);
                });

         ###