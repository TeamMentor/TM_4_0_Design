supertest         = require('supertest')
expect            = require('chai').expect
cheerio           = require('cheerio')
marked            = require('marked')
request           = require('request')
fs                = require('fs')
app               = require('../../server')
Jade_Service      = require('../../services/Jade-Service')
teamMentorContent = require('../../services/teamMentor-content.js')
Help_Controller   = require('../../controllers/Help-Controller.js')
    

describe.only 'routes |', ()->

    app.config.enable_Jade_Cache = true;       # enable Jade compilation cache (which dramatically speeds up tests)
    
    before ->
        app.server = app.listen(app.port);
        #preCompiler.disableCache = false;
        expect(teamMentorContent).to.be.an('Object');

###
    after (function() { app.server.close();                  });
        
    describe('test-help.js |', function() 
    {   
        it('should open page ok', function(done)
        {
            supertest(app).get('/help/index.html')
                          .expect(200,done);
        });
        
        it('open /default.html', function(done)
        {            
            supertest(app).get('/guest/default.html')
                          .expect(200)
                          .end(function(err, res)
                               {
                                    if(err) { throw err; }
                                    var $ = cheerio.load(res.text);
                                    expect($('a').length).to.be.above(7);
                                    expect($("a[href='/help/aaaaa.html'] ").length).to.be.empty;
                                    expect($("a[href='/help/index.html']" ).length).to.be.not.empty;                                                                        
                                    done();
                               });
        });
    });
    describe('test-help (dynamic content) |', function() 
    {               
        var libraryData  = teamMentorContent.getLibraryData_FromCache();         
        var pageParams   = { loggedIn : false}; 
        var helpJadeFile = '/source/html/help/index.jade';
         
        before(function()
        {
            expect(libraryData).to.be.an('Array');
            expect(libraryData).to.not.be.empty;
            
            var library = libraryData[0];
            
            expect(library      ).to.be.an('Object');
            expect(library.Views).to.not.be.empty;            
            
            pageParams.library = library;
            pageParams.content = "....";

        });
        
        var getHelpPageObject = function()
        {            
            var html                 = new Jade_Service().renderJadeFile(helpJadeFile, pageParams);   
            var $                    = cheerio.load(html);             
            return $;
        };
    

        it('check that index page markdown transform', function(done)
        {
            var page_index_File     = './source/content/page-index.md'   ; expect(fs.existsSync(page_index_File)).to.be.true;
            var page_index_Markdown = fs.readFileSync(page_index_File, "utf8"); expect(page_index_Markdown           ).to.contain('## TEAM Mentor Documents');  
            var page_index_Html     = marked(page_index_Markdown)             ; expect(page_index_Html               ).to.contain('<h2 id="team-mentor-documents">TEAM Mentor Documents</h2>');  
            
            supertest(app).get('/help/index.html')
                          .end(function(error,response)
                               {          
                                    if(error) { throw error; }                                    
                                    expect(response.text).to.contain(page_index_Html);
                                    done();
                               });
             
        });
        
        it('check that main content deliverer article', function(done) 
        {          
            this.timeout(5000);
            var article_Id    = 'dac20027-6138-4cd1-8888-3b7e6a007ea5';  
            var article_Line  = "<p><strong>To install TEAM Mentor Fortify SCA UI Integration</strong></p>";
            var article_Title = "<h2>Installation</h2>";
            console.log();
             supertest(app).get('/help/' + article_Id) 
                           .end(function(error,response)
                               {     
                                    expect(response.text).to.contain(article_Line);
                                    expect(response.text).to.contain(article_Title);
                                    done();
                               });
            
        });
        
        it('handle broken images bug', function(done)
        {         
            var gitHub_Path = 'https://raw.githubusercontent.com/TMContent/Lib_Docs/master/_Images/';
            var local_Path  = '/Image/';
            var test_image  = 'signup1.jpg';
            
            var check_For_Redirect = function()
                {                    
                    supertest(app).get(local_Path + test_image)
                                  .expect(302)
                                  .end(function(error, response)
                                        {
                                            expect(response.headers         ).to.be.an('Object');
                                            expect(response.headers.location).to.be.an('String');
                                            expect(response.headers.location).to.equal(gitHub_Path + test_image);
                                            check_That_Image_Exists(response.headers.location);
                                        });
                };
            var check_That_Image_Exists = function(image_Path)
                {                    
                    request.get(image_Path, function(error, response)
                        {
                            expect(response.statusCode).to.equal(200);
                            done();                         
                        });                          
                };
            
            check_For_Redirect();                            
        });
        
        it('check content_cache', function()
        {
            var help_Controller = new Help_Controller();
            expect(Help_Controller).to.be.an("Function");
            expect(help_Controller).to.be.an("Object");            
            expect(help_Controller.content_cache).to.be.an("Object");
        });
    });
});

###