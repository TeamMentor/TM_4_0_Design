/*jslint node: true , expr:true */
/*global describe, it ,before, after */
"use strict";

var supertest         = require('supertest')   ,    
    expect            = require('chai').expect ,
    cheerio           = require('cheerio')     ,
    //request           = require('request')     ,
    fs                = require('fs')          ,
    app               = require('../../server'),
    preCompiler       = require('../../services/jade-pre-compiler.js'),
    teamMentorContent = require('../../services/teamMentor-content.js');
    

describe('routes', function () 
{
    before(function() 
    { 
        app.server = app.listen(app.port);
        
        preCompiler.disableCache = false;  
        
        expect(teamMentorContent).to.be.an('Object'); 
        
        /*var targetPath = preCompiler.calculateTargetPath('/source/html/help/index.jade');
        if(fs.existsSync(targetPath))
        {
            fs.unlinkSync(targetPath); 
        }
        expect(fs.existsSync(targetPath)).to.be.false;*/
    });
    after (function() { app.server.close();                  });
        
    describe('test-help.js', function() 
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
    describe('test-help (dynamic content)', function() 
    {          
        it('check structure.json content', function ()
        {
            var structureFile  = process.cwd() + '/source/content/help/structure.json'; expect(fs.existsSync(structureFile)).to.be.true;
            var jsonContent    = fs.readFileSync(structureFile,"utf8")                ; expect(jsonContent                 ).to.contain("About TEAM Mentor"); 
            var content        = JSON.parse(jsonContent)                              ; expect(content                     ).to.be.an  ('Array');

            var folders = [];
            content.forEach(function(value) { folders.push(value.folder);});             
            expect(folders).to.contain("About TEAM Mentor")
                           .to.contain("Administration")
                           .to.contain("UI Elements");
            
            
            expect(content[0].views).to.deep.equal(["What is new in this release?",
                                                    "Introduction to TEAM Mentor",
                                                    "Quick Start Guide",
                                                    "Support"]);
            
            var structure = JSON.parse(fs.readFileSync(process.cwd() + '/source/content/help/structure.json'));
            expect(content).to.deep.equal(structure);
        });
        
        it('contents should match structure.json', function () 
        {                            
            //preCompiler.disableCache = true;  
            var libraryData = teamMentorContent.getLibraryData_FromCache(); 
            expect(libraryData).to.be.an('Array');
            expect(libraryData).to.not.be.empty;
            var library = libraryData[0];
            
            expect(library).to.be.an('Object');
            expect(library.Views).to.not.be.empty;
            
            
            //var structureFile = process.cwd() + '/source/content/help/structure.json';
            var jadeFile      = '/source/html/help/index.jade';
            //var structure     = JSON.parse(fs.readFileSync(structureFile));             
            
//            console.log(require('jade').renderFile(process.cwd() + jadeFile));
//            console.log('----------');
            
            var html          = preCompiler.renderJadeFile(jadeFile, { loggedIn : false , library : library} );   
            var $             = cheerio.load(html);             
            
            //console.log(libraryData);
            
            //var h4Texts = [];       
            //$('h4').each(function() { h4Texts.push($(this).text()); });         
            //console.log(h4Texts); 
            
            
            library.Views.forEach(function(view)
            { 
                var h4 = $('h4:contains(' + view.Title + ')'); 
                expect(h4.length).to.be.equal(1, 'could not find H4 with: "' + view.Title + '"'); 
                view.Articles.forEach(function(article)
                {
                    var li = $('li:contains(' + article.Title + ')'); 
                    expect(li.length).to.be.above(0, 'could not find li containing Tite: "' + article.Title + '"');
                    expect(li.length).to.be.above(0, 'could not find li containing Guid: "' + article.Id + '"');
                });
                //console.log(value);
            });
            
            /*structure.forEach(function(value) 
            {                
                var h4 = $('h4:contains(' + value.folder + ')');
                expect(h4.length).to.be.equal(1, 'could not find: ' + value.title);
                return;
            });*/
            
            //var h4Texts = [];      
            //$('h4').each(function() { h4Texts.push($(this).text()); });            
            //console.log(h4Texts); 
            /*var h4Texts = [];
            $('h4').each(function() { h4Texts.push($(this).text()); });
                    
            structure.forEach(function(value) 
            {
                expect(h4Texts).to.contain(value);    
            });*/
        }); 
         
        xit('open docs tm article', function(done)
        {
            var request = require('request');  
            var url = 'https://docs.teammentor.net/content/dac20027-6138-4cd1-8888-3b7e6a007ea5';
            request.get(url, function(error, response, body)  
                        {
                            if (error && error.code==="ENOTFOUND") { done(); return; }                                
                            expect(body).to.contain('<p><img src="/Image/ftins1.jpg" alt="" /> <br />');                             
                            // console.log(body);  
                            done();
                        });
        });        
    });
});