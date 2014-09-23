/*jslint node: true , expr:true */
/*global describe, it ,before, after */
"use strict";

var supertest         = require('supertest')   ,    
    expect            = require('chai').expect ,
    cheerio           = require('cheerio')     ,    
    marked            = require('marked')      ,
    request           = require('request')     , 
    fs                = require('fs')          ,    
    app               = require('../../server'),
    Jade_Service      = require('../../services/Jade-Service'),
    teamMentorContent = require('../../services/teamMentor-content.js'),
    Help_Controller   = require('../../controllers/Help-Controller.js');
    

describe('routes |', function () 
{
    app.config.enable_Jade_Cache = true;                        // enable Jade compilation cache (which dramatically speeds up tests)
    
    before(function() 
    { 
        app.server = app.listen(app.port);
        
        //preCompiler.disableCache = false;  
        
        expect(teamMentorContent).to.be.an('Object'); 
        
        /*var targetPath = preCompiler.calculateTargetPath('/source/html/help/index.jade');
        if(fs.existsSync(targetPath))
        {
            fs.unlinkSync(targetPath); 
        }
        expect(fs.existsSync(targetPath)).to.be.false;*/
    });
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
            supertest(app).get('/default.html')
                          .expect(200)
                          .end(function(err, res)
                               {
                                    if(err) { throw err; }
                                    var $ = cheerio.load(res.text);
                                    expect($('a').length).to.be.above(10);
                                    expect($("a[href='/help/aaaaa.html'] ").length).to.be.empty;
                                    expect($("a[href='/help/index.html']" ).length).to.be.not.empty;                                                                        
                                    done();
                               });
        });        
         
        it('open help from /default.html', function(done)
        {
            supertest(app).get('/default.html')
                          .expect(200)
                          .end(function(err, res)
                               {
                                    var $ = cheerio.load(res.text);
                                    var helpImgTag    = $("img[src='/deploy/assets/icons/help.png']").parent();
                                    var helpAnchorTag = helpImgTag.parent();
                
                                    expect(helpImgTag   ).to.be.an('object');
                                    expect(helpAnchorTag).to.be.an('object');
                
                                    expect(helpImgTag   .html()).to.equal('<img src="/deploy/assets/icons/help.png" alt="Help">');
                                    expect(helpAnchorTag.html()).to.equal('<a href="/help/index.html"><img src="/deploy/assets/icons/help.png" alt="Help"></a>');
                                    
                                    var helpUrl = helpAnchorTag.find('a').attr('href');                          
                                    expect(helpUrl).to.equal('/help/index.html');
                                    
                                    supertest(app).get(helpUrl)
                                                 .expect(200, done);
                
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
    
        it('check left-hand-side navivation', function () 
        {                      
            var $ = getHelpPageObject();
                                     
            //library.Views.forEach(function(view)    { });
            //view.Articles.forEach(function(article) { });   // no need to do all of these all the time
            
            var view    = pageParams.library.Views[0];
            var article = view.Articles[0];
            
            var h4 = $('h4:contains(' + view.Title + ')');                 
            expect(h4.length).to.be.equal(1, 'could not find H4 with: "' + view.Title + '"');                 
            
            var li = $('li:contains(' + article.Title + ')'); 
            expect(li.length).to.be.above(0, 'could not find li containing Tite: "' + article.Title + '"');
            expect(li.length).to.be.above(0, 'could not find li containing Guid: "' + article.Id + '"');                
            
        });  
        it('check mainContent', function () 
        {              
            var customContent  = '<h2>This is custom content....</h2>';  
            pageParams.content = customContent;
        
            var $ = getHelpPageObject(); 
            
            expect($.html()).to.contain(customContent);                 
        });
        it('check that index page markdown transform', function(done)
        {
            var page_index_File     = './source/content/docs/page-index.md'   ; expect(fs.existsSync(page_index_File)).to.be.true;
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