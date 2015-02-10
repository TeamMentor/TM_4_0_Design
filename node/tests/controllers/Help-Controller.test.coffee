supertest         = require('supertest')
expect            = require('chai').expect
request           = require('request')
app               = require('../../server')
marked            = require('marked')
Help_Controller   = require('../../controllers/Help-Controller')
TeamMentor_Service = require('../../services/TeamMentor-Service')


skip_Tests_If_Offline = (testSuite,next)=>
  url = "https://www.google.com"
  url.GET (html)=>
        if not html
          for test in testSuite.tests
            test.pending = true
        next()

describe 'controllers | Help-Controller.test', ()->

  #help_Server_Online = ->
  #  log new Help_Controller().docs_Server

  describe 'methods',->

    before (done)->
      skip_Tests_If_Offline @.test.parent, done


      #new Help_Controller().docs_Server.GET
      #@.test.parent.tests = []

    it 'ctor', ()->
      req = { a :42 }
      res = { b: 42 }
      using new Help_Controller(req,res),->
        @.assert_Is_Object()
        @.content_cache.assert_Is_Object()
        @.pageParams.assert_Is({})
        @.req.assert_Is(req)
        @.res.assert_Is(res)
        @.docs_Server.assert_Is 'https://docs.teammentor.net'
        assert_Is_Null(@.content)
        assert_Is_Null(@.page)
        assert_Is_Null(@.title)

    res = (text, done)->
            { status: (value)->
                          value.assert_Is(200)
                          @
              send: (html)->
                html.assert_Contains(text)
                done()
            }

    it 'getContent (index.html)', (done)->
      req      = { params: page: 'index.html' }
      res_Index = res('Welcome to the TEAM Mentor Documentation Website ',done)
      using new Help_Controller(req,res_Index),->
        @.page.assert_Is req.params.page
        @.getContent()

    it 'getContent (index.html, from cache)', (done)->
      req      = { params: page: 'index.html' }
      res_Index = res('Welcome to the TEAM Mentor Documentation Website ',done)
      using new Help_Controller(req,res_Index),->
        @.content_cache.keys().assert_Not_Empty()
        @.content_cache['index.html'].assert_Is_Object()
        @.content_cache['index.html'].content.assert_Is_String()
        @.getContent()

    it 'getContent (323dae88-b74b-465c-a949-d48c33f4ac85)', (done)->
      @timeout 3500
      req      = { params: page: '323dae88-b74b-465c-a949-d48c33f4ac85' }  # 323dae88-b74b-465c-a949-d48c33f4ac85 is 'Support' page
      res_Index = res('To contact Security Innovation TEAM Mentor support please email',done)
      using new Help_Controller(req,res_Index),->
        @.getContent()

    it 'getContent (non existing article)', (done)->
      req      = { params: page: 'abcdef' }
      res_Index = res('No content for the current page',done)
      using new Help_Controller(req,res_Index),->
        @.getContent()

    it 'handleFetchedHtml (with error',(done)->
      req      = { params: page: 'abcdef' }
      res_Index = res('Error fetching page from docs site',done)
      using new Help_Controller(req,res_Index),->
        @handleFetchedHtml({ code: 'ENOTFOUND'})


  describe 'misc workflows', ()->

    before (done)->
      skip_Tests_If_Offline @.test.parent, done

    this.timeout(3500)

    it 'request should add to cache', (done)->
      page = 'index.html'
      req = { params : { page : page}}
      res = { status : ()-> @ }
      help_Controller = new Help_Controller(req,res)

      help_Controller.content_cache[page] = undefined;

      checkRequestCache = (html)->
          cacheItem = help_Controller.content_cache[page];
          expect(cacheItem).to.be.an('Object');
          expect(cacheItem.title  ).to.equal(help_Controller.pageParams.title);
          expect(cacheItem.content).to.equal(help_Controller.pageParams.content);

          help_Controller.clearContentCache();

          expect(help_Controller.content_cache[page]).to.be.undefined;
          done()

      res.send =  checkRequestCache;
      expect(help_Controller.content_cache).to.be.an('Object')
      help_Controller.renderPage();


    it 'handle broken images bug', (done)->
      gitHub_Path = 'https://raw.githubusercontent.com/TMContent/Lib_Docs/master/_Images/'
      local_Path  = '/Image/'
      test_image  = 'signup1.jpg'

      check_For_Redirect = ()->
              supertest(app).get(local_Path + test_image)
                            .expect(302)
                            .end (error, response)->
                                      expect(response.headers         ).to.be.an('Object')
                                      expect(response.headers.location).to.be.an('String')
                                      expect(response.headers.location).to.equal(gitHub_Path + test_image)
                                      check_That_Image_Exists(response.headers.location)

      check_That_Image_Exists = (image_Path)->
              request.get image_Path, (error, response)->
                      expect(response.statusCode).to.equal(200);
                      done();
      check_For_Redirect()

  describe 'test-help (dynamic content) |', ()->

    before (done)->
      skip_Tests_If_Offline @.test.parent, done

    libraryData  = null
    pageParams   = { loggedIn : false};
    helpJadeFile = '/source/html/help/index.jade'

    before (done)->
      new TeamMentor_Service().getLibraryData (libraryData)->

        expect(libraryData).to.be.an('Array');
        expect(libraryData).to.not.be.empty;

        library = libraryData[0];

        library.assert_Is_Object()
        library.Views.assert_Is_Array()

        pageParams.library = library
        pageParams.content = "...."
        done()


    it 'check that index page markdown transform', (done)->
      root_Folder         = __dirname.path_Combine('../../..')
      page_index_File     = root_Folder.path_Combine('source/content/help/page-index.md').assert_File_Exists()
      page_index_Markdown = page_index_File.file_Contents() .assert_Contains('## TEAM Mentor Documents')
      page_index_Html     = marked(page_index_Markdown)     .assert_Contains('<h2 id="team-mentor-documents">TEAM Mentor Documents</h2>')

      supertest(app).get('/help/index.html')
                    .end (error,response)->
                      throw error if(error)
                      response.text.assert_Contains(page_index_Html);
                      done()


    it 'check that main content deliverer article', (done)->
      this.timeout(5000);
      article_Id    = 'dac20027-6138-4cd1-8888-3b7e6a007ea5';
      article_Line  = "<p><strong>To install TEAM Mentor Fortify SCA UI Integration</strong></p>";
      article_Title = "<h2>Installation</h2>";

      supertest(app).get('/help/' + article_Id)
                    .end (error,response)->
                      expect(response.text).to.contain(article_Line);
                      expect(response.text).to.contain(article_Title);
                      done()

    it 'check content_cache', ()->
      help_Controller = new Help_Controller()
      expect(Help_Controller).to.be.an("Function")
      expect(help_Controller).to.be.an("Object")
      expect(help_Controller.content_cache).to.be.an("Object")