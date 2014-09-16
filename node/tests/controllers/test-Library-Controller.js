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
                        expect($('#links-libraries a'   ).length).to.equal(6);                        
                        expect($('#link-my-articles'    ).html()).to.equal('My Articles'); 
                        expect($('#link-my-search-items').html()).to.equal('My Search Items'); 
 

                        var docsLink = $('#link-library-' + libraries.docs.id);
                        expect(docsLink.length).to.be.above(0);
                        expect(docsLink.html()).to.equal(libraries.docs.title);
                        expect(docsLink.attr('href')).to.equal('/library/' + libraries.docs.name);
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
                        expect($('#links-libraries a'   ).length).to.equal(6);                        
                        expect($('#link-my-articles'    ).html()).to.equal('My Articles'); 
                        expect($('#link-my-search-items').html()).to.equal('My Search Items'); 
                        
                        expect($('#links-library a'   ).length).to.equal(9);                        
                        
                        //console.log(html);
                        //console.log(html); 
                        done();
                    };
                supertest(app).get('/library/docs')    
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
            //preCompiler.disableCache =false; 
            var checkPageContents = function(html)   
                    {    
                        /*var $ = cheerio.load(html);
                        expect($('#links-libraries a'   ).length).to.equal(6);                        
                        expect($('#link-my-articles'    ).html()).to.equal('My Articles'); 
                        expect($('#link-my-search-items').html()).to.equal('My Search Items'); 
                        
                        expect($('#links-library a'   ).length).to.equal(9);                        */
                        
                        //console.log(html);
                        
                        console.log(html);   
                        done();
                    };
                supertest(app).get('/library/Uno/folder/Security Engineering')       
                              .expect(200) 
                              .end(function(error, response) 
                                   {   
                                        if(error) { throw error;}                                                                                    
                                        checkPageContents(response.text); 
                                   });

            });
    });

    describe('internal Functions.js', function() 
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

                expect(libraries.docs       ).to.be.an('Object'); 
                expect(libraries.docs.id    ).to.be.an('String'); 
                expect(libraries.docs.repo  ).to.be.an('String'); 
                expect(libraries.docs.site  ).to.be.an('String'); 
                expect(libraries.docs.title ).to.be.an('String'); 

                expect(libraries.docs.name  ).to.equal('docs' ); 
                expect(libraries.docs.id    ).to.equal('eb39d862-f752-4d1c-ab6e-14ed697397c0'); 
                expect(libraries.docs.repo  ).to.equal('https://github.com/TMContent/Lib_Docs'); 
                expect(libraries.docs.site  ).to.equal('https://docs.teammentor.net/'); 
                expect(libraries.docs.title ).to.equal('TM Documentation'); 

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
                
                var docs = libraries.docs;
                expect(docs).to.be.defined;
                
                libraries.docs.data = null;
                
                library_Controller.mapLibraryData(docs, function()
                    {
                        expect(docs.data).to.be.not.null;
                        var data = docs.data;            
                    
                        expect(data).to.be.an('object');
                    
                        expect(data.name).to.be.an('String');
                        expect(data.libraryId).to.be.an('String');
                        expect(data.guidanceItems).to.be.an('Array');
                    
                        expect(data.name     ).to.equal('TM Documentation');
                        expect(data.libraryId).to.equal('eb39d862-f752-4d1c-ab6e-14ed697397c0');
                    
                        library_Controller.mapLibraryData(docs, function()
                            {                                
                                expect(docs.data).to.equal(data);
                                done(); 
                            });
                        
                    });
            });
    });

});

//use to create file with html contents
//fs.writeFileSync('./tmp.html',response.text);    
//require('child_process').spawn('open',['./tmp.html']);                    