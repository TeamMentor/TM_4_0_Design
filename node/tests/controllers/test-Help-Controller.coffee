supertest         = require('supertest')
expect            = require('chai').expect
request           = require('request')
app               = require('../../server')
Help_Controller   = require('../../controllers/Help-Controller.js')

describe 'controllers |', ()->
    describe 'test-Help-Controller.js |', ()->

        this.timeout(3500)
        
        describe 'content_cache', ()->
            it 'check ctor', ()->
                help_Controller = new Help_Controller();
                expect(Help_Controller).to.be.an("Function");
                expect(help_Controller).to.be.an("Object");
                expect(help_Controller.content_cache).to.be.an("Object");
                expect(help_Controller.title        ).to.equal(null);
                expect(help_Controller.content      ).to.equal(null);
            
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