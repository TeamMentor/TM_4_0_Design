/*jslint node: true , expr:true */
/*global describe, it */
"use strict";

var //fs                 = require('fs'),
    supertest          = require('supertest')   ,    
    cheerio            = require('cheerio')   ,    
    expect             = require('chai').expect ,        
    //request           = require('request')     ,    
    app                = require('../../server'),    
    Library_Controller = require('../../controllers/Library-Controller.js');
    //preCompiler        = require(process.cwd() + '/node/services/jade-pre-compiler.js');

describe('controllers | test-Library-Controller.js |', function () 
{
    describe('used by controllers', function() 
    {            
        var libraries = new Library_Controller().libraries;

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
                        
                        //console.log(html);   
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

                expect(libraryController    ).to.be.an('Object');
                expect(libraryController.libraries).to.be.an('Object');
                expect(libraryController.req).to.deep.equal(req);
                expect(libraryController.res).to.deep.equal(res);

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
                                expect(library.data).to.equal(data);                // previous object should had been reused
                                done(); 
                            });
                        
                    });
            });
    });

});

//use to create file with html contents
//fs.writeFileSync('./tmp.html',response.text);    
//require('child_process').spawn('open',['./tmp.html']);                    