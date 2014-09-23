/*jslint node: true , expr:true */
/*global describe, it */
"use strict";

var fs                 = require('fs'),
    path               = require('path'),
    supertest          = require('supertest')   ,    
    cheerio            = require('cheerio')   ,    
    expect             = require('chai').expect ,            
    app                = require('../../server'),    
    Config             = require('../../Config'),
    Library_Controller = require('../../controllers/Library-Controller.js');    

describe('controllers | test-Library-Controller.js |', function () 
{    
    describe('used by controllers', function()
    {
        app.config.enable_Jade_Cache = true;                        // enable Jade compilation cache (which dramatically speeds up tests)
                
        var libraries = new Library_Controller().libraries;

        it("/config", function(done) 
        {
            supertest(app).get('/config')
                          .expect(200, app.config        , done);                      
        });

        it('/libraries', function(done) 
           {   
                var checkPageContents = function(html)  
                    {    
                        var $ = cheerio.load(html);
                        expect($('#links-libraries a'   ).length).to.equal(4);                        
                        expect($('#link-my-articles'    ).html()).to.equal('My Articles'); 
                        expect($('#link-my-search-items').html()).to.equal('My Search Items'); 
 

                        var docsLink = $('#link-library-' + libraries.Uno.id);
                        expect(docsLink.length).to.be.above(0);
                        expect(docsLink.html()).to.equal(libraries.Uno.title);
                        expect(docsLink.attr('href')).to.equal('/library/' + libraries.Uno.name);
                        done();  
                    };   

                supertest(app).get('/libraries')    
                              .expect(200)
                              .end(function(error, response) 
                                   {   
                                        if(error) { throw error;}                                            
                                        checkPageContents(response.text); 
                                   });
           });
         it('/library/{good value}', function(done)
           {   
            //preCompiler.disableCache =false; 
            var checkPageContents = function(html)  
                    {    
                        var $ = cheerio.load(html);
                        expect($('#links-libraries a'   ).length).to.equal(4);                        
                        expect($('#link-my-articles'    ).html()).to.equal('My Articles'); 
                        expect($('#link-my-search-items').html()).to.equal('My Search Items'); 
                        
                        expect($('#links-library a'   ).length).to.equal(13);                        
                        
                        //console.log(html);
                        //console.log(html); 
                        done();
                    };
                supertest(app).get('/library/Uno')    
                              .expect(200) 
                              .end(function(error, response) 
                                   {   
                                        if(error) { throw error;}                                                                                    
                                        checkPageContents(response.text); 
                                   });

            });
        it('/library/{bad value}', function(done) 
           {   

                supertest(app).get('/library/AAABBBCC')    
                              .expect(302)
                              .end(function(error, response) 
                                   {   
                                        expect(response.headers.location).to.equal('/Libraries');
                                        done();
                                   });                                     
            });
        
        it('/library/{good value}/folder/{good value}', function(done) 
           {   
            var checkPageContents = function(html)   
                    {    
                        var $ = cheerio.load(html);
                        expect($('h3').html()).to.equal('Authentication');                        
                        done();
                    };
                supertest(app).get('/library/Uno/folder/Authentication')       
                              .expect(200) 
                              .end(function(error, response) 
                                   {   
                                        if(error) { throw error;}                                                                                    
                                        checkPageContents(response.text); 
                                   });
            });
    });

    describe('internal Functions.js |', function() 
    {
        it('check ctor', function() 
            {
                var req = {};
                var res = {};
                var libraryController = new Library_Controller(req, res);

                expect(libraryController          ).to.be.an('Object');
                expect(libraryController.libraries).to.be.an('Object');
                expect(libraryController.req      ).to.deep.equal(req);
                expect(libraryController.res      ).to.deep.equal(res);
                expect(libraryController.config   ).to.deep.equal(new Config());
                
                expect(libraryController.jade_Service.config        ).to.be.an('Object');
                expect(libraryController.jade_Service.config.version).to.equal(new Config().version);
                var customConfig = new Config();
                var customVersion    = "aa.bb.cc";
                customConfig.version = customVersion;
                var custom_libraryController = new Library_Controller(req, res, customConfig);
                expect(custom_libraryController.config                     ).to.equal(customConfig);
                expect(custom_libraryController.jade_Service.config        ).to.equal(customConfig);
                expect(custom_libraryController.jade_Service.config.version).to.equal(customVersion);

            });
        it('check default libraries mappings', function ()
            {
                var libraries = new Library_Controller().libraries;
                expect(libraries).to.be.an('Object'); 

                expect(libraries.Uno       ).to.be.an('Object'); 
                expect(libraries.Uno.id    ).to.be.an('String'); 
                expect(libraries.Uno.repo  ).to.be.an('String'); 
                expect(libraries.Uno.site  ).to.be.an('String'); 
                expect(libraries.Uno.title ).to.be.an('String'); 

                expect(libraries.Uno.name  ).to.equal('Uno' ); 
                expect(libraries.Uno.id    ).to.equal('be5273b1-d682-4361-99d9-6234f2d47eb7'); 
                expect(libraries.Uno.repo  ).to.equal('https://github.com/TMContent/Lib_UNO'); 
                expect(libraries.Uno.site  ).to.equal('https://tmdev01-sme.teammentor.net/'); 
                expect(libraries.Uno.title ).to.equal('Index'); 

                /*expect(libraries.vulns      ).to.be.an('Object'); 
                expect(libraries.vulns.name ).to.equal('vulns'); 
                expect(libraries.vulns.id   ).to.equal('be5273b1-d682-4361-99d9-6204f2d47eb7'); 
                expect(libraries.vulns.repo ).to.equal('https://github.com/TMContent/Lib_Vulnerabilities'); 
                expect(libraries.vulns.site ).to.equal('https://tmdev01-sme.teammentor.net/'); 
                expect(libraries.vulns.title).to.equal('Vulnerabilities');*/


                expect(libraries.ABC        ).to.not.be.an('Object'); 

            });
                        
            it('mapLibraryData', function(done)
            {
                var library_Controller  = new Library_Controller();
                var libraries           = library_Controller.libraries;
                                                
                var library_Key  = "Uno";
                var library_Name = "UNO";
                var library_ID   = 'be5273b1-d682-4361-99d9-6234f2d47eb7';
                
                var library      = libraries[library_Key];
                expect(library).to.be.defined;
                
                libraries.Uno.data = null;
                
                library_Controller.mapLibraryData(library, function()
                    {
                        expect(library.data).to.be.not.null;
                        var data = library.data;            
                    
                        expect(data).to.be.an('object');
                    
                        expect(data.name).to.be.an('String');
                        expect(data.libraryId).to.be.an('String');
                        expect(data.guidanceItems).to.be.an('Array');
                    
                        expect(data.name     ).to.equal(library_Name);  
                        expect(data.libraryId).to.equal(library_ID);
                            
                    
                        library_Controller.mapLibraryData(library, function()
                            {                                
                                expect(library.data).to.deep.equal(data);                // previous object should had been reused
                                done(); 
                            });
                    });
            });
            
            it('mapLibraryData (using cache', function(done)
            {
                var library_Controller  = new Library_Controller();
                var libraryData = { some : 'data'};
                var library     = { id : 'abc123' , data: libraryData};
                var cacheFile   = library_Controller.cacheLibraryData(library);                
                expect(fs.existsSync(cacheFile)).to.be.true;
                
                library.data    = null;                                             // reset it so that we can confirm it was set
                
                library_Controller.mapLibraryData(library, function()
                    {
                        fs.unlinkSync(cacheFile);
                        expect(fs.existsSync(cacheFile)).to.be.false;
                        done();
                    });                                    
            });
            it('cachedLibraryData', function()
            {            
                var library_Controller  = new Library_Controller();
                expect(library_Controller.cachedLibraryData).to.be.an('Function');
                expect(library_Controller.cachedLibraryData()).to.equal(null);
                
                var libraryId   =  'abc123';
                var libraryJson = '{ "id" : "' + libraryId +'", "name" : "' + libraryId +'"}';
                var library        = { id : libraryId };
                var cacheFile      = library_Controller.cachedLibraryData_File(library);
                
                fs.writeFileSync(cacheFile, libraryJson);
                expect(fs.existsSync(cacheFile)).to.be.true;
                
                var libraryData = library_Controller.cachedLibraryData(library);
                expect(libraryData).to.be.an('Object');
                expect(libraryData.id   ).to.equal    (libraryId);
                expect(libraryData.name ).to.equal    (libraryId);
                expect(libraryData.abc  ).to.not.equal(libraryId);
                fs.unlinkSync(cacheFile);
                expect(fs.existsSync(cacheFile)).to.be.false;
            });
            it('cacheLibraryData', function()
            {
                var library_Controller  = new Library_Controller();
                expect(library_Controller.cacheLibraryData).to.be.an('Function');
                expect(library_Controller.cacheLibraryData()).to.equal(null);
                                   
                var library     = { id : 'abc123' };
                var cacheFile   = library_Controller.cachedLibraryData_File(library);
                
                expect(library_Controller.cacheLibraryData(library)).to.equal(cacheFile);
                
                var fileContents = fs.readFileSync(cacheFile, 'utf8');
                expect(fileContents).to.equal(JSON.stringify(library));                
                expect(JSON.parse(fileContents)).to.deep.equal(library);
                
                fs.unlinkSync(cacheFile);
                expect(fs.existsSync(cacheFile)).to.be.false;
            });
            
            it('cachedLibraryData_Path', function()
            {
                var libraryId   =  'abc123';
                var library_Controller  = new Library_Controller();
                var library        = { id : libraryId };
                var expectedPath   = path.join(library_Controller.config.library_Data, libraryId + ".json");
               
                expect(library_Controller.cachedLibraryData_File(null)).to.equal(null);
                expect(library_Controller.cachedLibraryData_File(library)).to.equal(expectedPath);
            });
    });

});

//use to create file with html contents
//fs.writeFileSync('./tmp.html',response.text);    
//require('child_process').spawn('open',['./tmp.html']);                    